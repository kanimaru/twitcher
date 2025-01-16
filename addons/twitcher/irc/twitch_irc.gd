@tool
extends Node

class_name TwitchIRC

static var log: TwitchLogger = TwitchLogger.new("TwitchIRC")

## Sent when the bot or moderator removes all messages from the chat room or removes all messages for the specified user.
signal received_clearchat(channel_name: String, banned_or_timeout_user: String, tags: TwitchTags.ClearChat)
## Sent when the bot removes a single message from the chat room.
signal received_clearmsg(channel_name: String, chat_message_removed: String, tags: TwitchTags.ClearMsg)
## Sent after the bot authenticates with the server.
signal received_global_userstate(tags: TwitchTags.GlobalUserState)
## Sent when a channel starts or stops hosting viewers from another channel.
signal received_host_target(channel_being_hosted: String, hosting_channel: String, number_of_viewers: int)
## Sent to indicate the outcome of an action like banning a user.[br]
## handled = when the Twitcher already handled the message.
signal received_notice(channel_name: String, message: String, tags: TwitchTags.Notice, handled: bool)
## Sent when the Twitch IRC server needs to terminate the connection for maintenance reasons. This gives your bot a chance to perform minimal clean up and save state before the server terminates the connection. The amount of time between receiving the message and the server closing the connection is indeterminate.
signal received_reconnect
## Sent when the bot joins a channel or when the channel’s chat settings change.
signal received_roomstate(channel_name: String, tags: TwitchTags.Roomstate)
## Sent when events like someone subscribing to the channel occurs. [br]
## - A user subscribes to the channel, re-subscribes to the channel, or gifts a subscription to another user.[br]
## - Another broadcaster raids the channel. Raid is a Twitch feature that lets broadcasters send their viewers to another channel to help support and grow other members in the community.[br]
## - A viewer milestone is celebrated such as a new viewer chatting for the first time.
signal received_usernotice(channel_name: String, message: String, tags: TwitchTags.Usernotice)
## Sent when the bot joins a channel or sends a PRIVMSG message.
signal received_userstate(channel_name: String, tags: TwitchTags.Userstate)
## Sent when a WHISPER message is directed specifically to your bot. Your bot will never receive whispers sent to other users.[br]
## from_user - The user that’s sending the whisper message.[br]
## to_user - The user that’s receiving the whisper message.
signal received_whisper(from_user: String, to_user: String, message: String, tags: TwitchTags.Whisper)
## The Twitch IRC server sends this message after a user posts a message to the chat room.
signal received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg)
## When the token isn't valid anymore
signal unauthenticated
## When the token doesn't have enough permissions to join IRC
signal unauthorized
## Called when the connection got opened and the authorization was done
signal connection_opened
## Called when the connection got closed
signal connection_closed


enum JoinState {
	NOT_JOINED, JOINING, JOINED
}

class ChannelData extends RefCounted:

	signal has_joined

	var join_state: JoinState = JoinState.NOT_JOINED
	var channel_name: String
	var nodes: Array[TwitchIrcChannel] = []
	var user_state: TwitchTags.Userstate
	var room_state: TwitchTags.Roomstate:
		set(val):
			room_state = val
			if join_state != JoinState.JOINED && val != null:
				join_state = JoinState.JOINED
				has_joined.emit()

	func _init(channel: String) -> void:
		channel_name = channel

	func leave() -> void:
		room_state = null
		join_state = JoinState.NOT_JOINED
		for node in nodes: node.leave()

	func is_joined() -> void:
		if join_state != JoinState.JOINED: await has_joined


class ParsedMessage extends RefCounted:
	## Parses all of the messages of IRC
	## Group1: Tags
	## Group2: Server / To User (Whisper) / From User (Chat)
	## Group3: Command
	## Group4: Channel / From User (Whisper)
	## Group5: Message / Payload
	var _irc_message_parser_regex = RegEx.create_from_string("(@.*? )?:(.*?)( [A-Z0-9]*)( #?.*?)?( :.*?)?$")

	var tags: String:
		get: return tags.trim_prefix("@")

	## Server / To User (Whisper) / From User (Chat)
	var server: String

	var command: String:
		get: return command.strip_edges()

	## Channel / From User (Whisper)
	var channel: String:
		get: return channel.strip_edges().trim_prefix("#")

	## Message / Payload
	var message: String:
		get: return message.strip_edges().trim_prefix(":")

	func _init(msg: String) -> void:
		var matches = _irc_message_parser_regex.search(msg)
		if matches != null:
			tags = matches.get_string(1)
			server = matches.get_string(2)
			command = matches.get_string(3)
			channel = matches.get_string(4)
			message = matches.get_string(5)


class EmoteLocation extends RefCounted:
	var id : Variant
	var start : int
	var end : int
	var sprite_frames: SpriteFrames

	func _init(emote_id: Variant, start_idx: int, end_idx: int):
		self.id = emote_id
		self.start = start_idx
		self.end = end_idx

	static func smaller(a : EmoteLocation, b : EmoteLocation):
		return a.start < b.start


@export var setting: TwitchIrcSetting = TwitchIrcSetting.new():
	set = _update_setting
@export var token: OAuthToken:
	set(val):
		token = val
		update_configuration_warnings()
@export var irc_send_message_delay: int = 360
## All connected channels of the bot.
## Key: channel_name as StringName | Value: ChannelData
var _channels := {}

## will automatically reconnect in case of authorization problems
var _auto_reconnect: bool
var _ready_to_send: bool
var _client := WebsocketClient.new()

## Timestamp when the next message should be sent.
var _next_message := Time.get_ticks_msec()

## Messages to send with an interval for disconnection protection
## see TwitchIrcSetting.send_message_delay_ms.
var _chat_queue : Array[String] = []


func _init() -> void:
	_client.message_received.connect(_data_received)
	_client.connection_established.connect(_on_connection_established)
	_client.connection_closed.connect(_on_connection_closed)


func _update_setting(twitch_irc_setting: TwitchIrcSetting) -> void:
	setting = twitch_irc_setting
	_client.connection_url = setting.server


func _ready() -> void:
	token.authorized.connect(_on_authorized)
	add_child(_client)


func _on_authorized() -> void:
	log.i("Token got authorized reconnect to irc? Client Closed: %s, Auto Reconnect enabled: %s" % [_client.is_closed, _client.auto_reconnect])
	if _client.is_closed and _auto_reconnect:
		open_connection()


## Propergated call from TwitchService
func do_setup() -> void:
	await open_connection()
	log.i("IRC setup")


func open_connection() -> void:
	_auto_reconnect = true
	log.i("Irc open connection")
	await _client.open_connection()


func close_connection() -> void:
	_auto_reconnect = false
	_client.close(1000, "intentionally closed")
	log.i("Irc closed connection")


func _on_connection_established() -> void:
	_login()
	_reconnect_to_channels()
	connection_opened.emit()


func _on_connection_closed() -> void:
	_ready_to_send = false
	connection_closed.emit()
	for channel_name: StringName in _channels:
		_channels[channel_name].leave()


func _process(delta: float) -> void:
	if _ready_to_send: _send_messages()


## Sends the login message for authorization pupose and sets an username
func _login() -> void:
	_client.send_text("PASS oauth:%s" % token.get_access_token())
	_send("NICK " + setting.username)
	_send("CAP REQ :" + " ".join(setting.irc_capabilities))


## Reconnect to all channels the bot was joined before (in case programatically joined channels)
func _reconnect_to_channels():
	for channel_name in _channels: join_channel(channel_name)


func _join_channels_on_connect():
	for channel_name: StringName in setting.auto_join_channels:
		var channel = join_channel(channel_name)
		await channel.is_joined()
		log.i("%s joined" % channel_name)


## Receives data on the websocket aka new messages
func _data_received(data : PackedByteArray) -> void:
	var messages : PackedStringArray = data.get_string_from_utf8().strip_edges(false).split("\r\n")
	for message: String in messages:
		# Reminder PONG messages is just different cant use match for it...
		if message.begins_with("PING"):
			_send("PONG :tmi.twitch.tv")
			continue

		var parsed_message = ParsedMessage.new(message)
		_handle_message(parsed_message)


## Tries to send messages as long as the websocket is open
func _send_messages() -> void:
	if _chat_queue.is_empty():
		return

	if not _client.is_open:
		log.e("Can't send message. Connection not open.")
		# Maybe buggy when the websocket got opened but not authorized yet
		# Can possible happen when we have a lot of load and a reconnect in the socket
		return

	if _next_message <= Time.get_ticks_msec():
		var msg_to_send = _chat_queue.pop_front()
		_send(msg_to_send)
		_next_message = Time.get_ticks_msec() + irc_send_message_delay


## Sends join channel message
func join_channel(channel_name : StringName) -> ChannelData:
	var lower_channel = channel_name.to_lower()
	if not _channels.has(channel_name):
		_channels[channel_name] = ChannelData.new(lower_channel)

	if _channels[channel_name].join_state == JoinState.NOT_JOINED:
		_chat_queue.append("JOIN #" + lower_channel)
		_channels[channel_name].join_state = JoinState.JOINING

	return _channels[channel_name]


## Sends leave channel message
func leave_channel(channel_name : StringName) -> void:
	if not _channels.has(channel_name):
		log.e("Can't leave %s channel cause we are not joined" % channel_name)
		return

	var lower_channel : StringName = channel_name.to_lower()
	_chat_queue.append("PART #" + lower_channel)
	_channels.erase(lower_channel)


## Sends a chat message to a channel. Defaults to the only connected channel.
## Channel should be always without '#'.
func chat(message : String, channel_name : StringName = &""):
	var channel_names : Array = _channels.keys()
	if channel_name == &"" && channel_names.size() == 1:
		channel_name = channel_names[0]

	if channel_name == &"":
		log.e("No channel is specified to send %s" % message)
		return

	_chat_queue.append("PRIVMSG #%s :%s\r\n" % [channel_name, message])

	# Call it defered otherwise the response of the bot will be send before the command.
	_send_message_to_channel.call_deferred(channel_name, message)


## send the message of the bot to the channel for display purpose
func _send_message_to_channel(channel_name: StringName, message: String) -> void:
	if _channels.has(channel_name):
		var channel = _channels[channel_name] as ChannelData
		var username = channel.user_state.display_name
		# Convert the tags in a dirty way
		var tag = TwitchTags.PrivMsg.new(channel.user_state._raw)
		tag.room_id = channel.room_state.room_id
		received_privmsg.emit(channel_name, username, message, tag)


## Sends a string message to Twitch.
func _send(text : String) -> void:
	_client.send_text(text)
	log.i("< " + text.strip_edges(false))


## Handles all the messages. Tags can be empty when not requested via capabilities
func _handle_message(parsed_message : ParsedMessage) -> void:
	if parsed_message.command != "WHISPER":
		log.i("> [%15s] %s: %s" % [parsed_message.command, parsed_message.server, parsed_message.message])

	match parsed_message.command:
		"001":
			log.i("Authentication successful.")
			_join_channels_on_connect()
			_ready_to_send = true

		"CLEARCHAT":
			var clear_chat_tags = TwitchTags.ClearChat.new(parsed_message.tags)
			var user_to_ban_or_timeout = parsed_message.message
			received_clearchat.emit(parsed_message.channel, parsed_message.message, clear_chat_tags)

		"CLEARMSG":
			var clear_msg_tags = TwitchTags.ClearMsg.new(parsed_message.tags)
			var message_to_remove = parsed_message.message
			received_clearmsg.emit(parsed_message.channel, message_to_remove, clear_msg_tags)

		"GLOBALUSERSTATE":
			var global_userstate = TwitchTags.GlobalUserState.new(parsed_message.tags)
			received_global_userstate.emit(global_userstate)

		"HOSTTARGET":
			# Example: [-|<channel>] <number-of-viewers>
			var host_target_message = parsed_message.message.split(" ")
			var channel_being_hosted = host_target_message[0]
			var number_of_viewers = int(host_target_message[1])
			var hosting_channel = parsed_message.channel
			received_host_target.emit(channel_being_hosted, hosting_channel, number_of_viewers)

		"NOTICE":
			var notice_tags = TwitchTags.Notice.new(parsed_message.tags)
			var message = parsed_message.message
			var handled := false
			if not await _handle_cmd_notice(message):
				handled = true
			received_notice.emit(parsed_message.channel, message, notice_tags, handled)

		"RECONNECT":
			received_reconnect.emit()

		"ROOMSTATE":
			var roomstate_tags = TwitchTags.Roomstate.new(parsed_message.tags)
			var channel_name = parsed_message.channel
			received_roomstate.emit(channel_name, roomstate_tags)

			var channel = _channels[channel_name] as ChannelData
			channel.room_state = roomstate_tags

		"USERNOTICE":
			var user_notice_tags = TwitchTags.Usernotice.new(parsed_message.tags)
			received_usernotice.emit(parsed_message.channel, parsed_message.message, user_notice_tags)

		"USERSTATE":
			var userstate_tags = TwitchTags.Userstate.new(parsed_message.tags)
			var channel_name = parsed_message.channel
			received_usernotice.emit(channel_name, userstate_tags)

			var channel = _channels[channel_name] as ChannelData
			channel.user_state = userstate_tags

		"WHISPER":
			var whisper_tags = TwitchTags.Whisper.new(parsed_message.tags)
			# Example: :<to-user>!<to-user>@<to-user>.tmi.twitch.tv
			var to_user = parsed_message.server
			to_user = to_user.substr(0, to_user.find("!"))
			# Special case for whisper
			var from_user = parsed_message.channel
			received_whisper.emit(from_user, to_user, parsed_message.message, whisper_tags)

		"PRIVMSG":
			var privmsg_tags = TwitchTags.PrivMsg.new(parsed_message.tags)
			var from_user = parsed_message.server
			from_user = from_user.substr(0, from_user.find("!"))
			received_privmsg.emit(parsed_message.channel, from_user, parsed_message.message, privmsg_tags)


## Handles the update of rooms when joining the channel or a moderator
## updates it (Example :tmi.twitch.tv ROOMSTATE #bar)
func _handle_cmd_state(command: String, channel_name: StringName, tags: Dictionary) -> void:
	# right(-1) -> Remove the preceding # of the channel name
	channel_name = channel_name.right(-1).to_lower()
	if not _channels.has(channel_name):
		_channels[channel_name] = _create_channel(channel_name)

	var channel: TwitchIrcChannel = _channels[channel_name]
	channel.update_state(command, tags)
	#channel_data_updated.emit(channel_name, channel.data)
	log.i("Channel updated %s" % channel_name)


func _create_channel(channel_name: StringName) -> TwitchIrcChannel:
	var channel = TwitchIrcChannel.new()
	channel.channel_name = channel_name
	_channels[channel_name] = channel
	Engine.get_main_loop().root.add_child(channel)
	return channel


## Tracks the channel.
func add_channel(channel: TwitchIrcChannel):
	var channel_name = channel.channel_name
	if not _channels.has(channel_name):
		join_channel(channel_name)
	var nodes = _channels[channel_name].nodes as Array[TwitchIrcChannel]
	nodes.append(channel)


## Remove the channel from getting tracked within the service
func remove_channel(channel: TwitchIrcChannel):
	var channel_name = channel.channel_name
	var channel_data = _channels[channel_name] as ChannelData
	channel_data.nodes.erase(channel)
	if channel_data.nodes.is_empty():
		leave_channel(channel_name)


func _handle_cmd_notice(info: String) -> bool:
	if info == "Login authentication failed" || info == "Login unsuccessful":
		log.e("Authentication failed.")
		unauthenticated.emit()
		_client.close(1000, "Unauthenticated.")
		return true
	elif info == "You don't have permission to perform that action":
		log.i("No permission. Please check if you have all required scopes (chat:read or chat:write).")
		unauthorized.emit()
		_client.close(1000, "Token became invalid.")
		return true
	return false


func get_client() -> WebsocketClient:
	return _client

func _get_configuration_warnings() -> PackedStringArray:
	var result: Array[String] = []
	if token == null:
		result.append("Token is missing")
	return result
