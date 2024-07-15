extends RefCounted

class_name TwitchIRC

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_IRC);

## Sent when the bot or moderator removes all messages from the chat room or removes all messages for the specified user.
signal received_clearchat(channel_name: String, banned_or_timeout_user: String, tags: TwitchTags.ClearChat);
## Sent when the bot removes a single message from the chat room.
signal received_clearmsg(channel_name: String, chat_message_removed: String, tags: TwitchTags.ClearMsg);
## Sent after the bot authenticates with the server.
signal received_global_userstate(tags: TwitchTags.GlobalUserState);
## Sent when a channel starts or stops hosting viewers from another channel.
signal received_host_target(channel_being_hosted: String, hosting_channel: String, number_of_viewers: int);
## Sent to indicate the outcome of an action like banning a user.[br]
## handled = when the Twitcher already handled the message.
signal received_notice(channel_name: String, message: String, tags: TwitchTags.Notice, handled: bool);
## Sent when the Twitch IRC server needs to terminate the connection for maintenance reasons. This gives your bot a chance to perform minimal clean up and save state before the server terminates the connection. The amount of time between receiving the message and the server closing the connection is indeterminate.
signal received_reconnect();
## Sent when the bot joins a channel or when the channel’s chat settings change.
signal received_roomstate(channel_name: String, tags: TwitchTags.Roomstate);
## Sent when events like someone subscribing to the channel occurs. [br]
## - A user subscribes to the channel, re-subscribes to the channel, or gifts a subscription to another user.[br]
## - Another broadcaster raids the channel. Raid is a Twitch feature that lets broadcasters send their viewers to another channel to help support and grow other members in the community.[br]
## - A viewer milestone is celebrated such as a new viewer chatting for the first time.
signal received_usernotice(channel_name: String, message: String, tags: TwitchTags.Usernotice);
## Sent when the bot joins a channel or sends a PRIVMSG message.
signal received_userstate(channel_name: String, tags: TwitchTags.Userstate);
## Sent when a WHISPER message is directed specifically to your bot. Your bot will never receive whispers sent to other users.[br]
## from_user - The user that’s sending the whisper message.[br]
## to_user - The user that’s receiving the whisper message.
signal received_whisper(from_user: String, to_user: String, message: String, tags: TwitchTags.Whisper);
## The Twitch IRC server sends this message after a user posts a message to the chat room.
signal received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg);

## Websocket client to communicate with the Twitch IRC server.
var client: WebsocketClient = WebsocketClient.new();

## Timestamp when the next message should be sent.
var next_message : int = Time.get_ticks_msec();

## Messages to send with an interval for disconnection protection
## see TwitchSettings.irc_send_message_delay.
var chat_queue : Array[String] = []

## All connected channels of the bot. Contains Key: channel_name -> Value: ChannelData entries.
var channel_maps : Dictionary = {}

## Returns everything between ! and @ example message looks like:
## :foo!foo@foo.tmi.twitch.tv PRIVMSG #bar :bleedPurple
var user_regex : RegEx = RegEx.create_from_string("!([\\w]*)@")

class ChannelData extends RefCounted:

	signal has_joined;

	var joined: bool;
	var channel_name: String;
	var nodes: Array[TwitchIrcChannel] = [];
	var user_state: TwitchTags.Userstate;
	var room_state: TwitchTags.Roomstate:
		set(val):
			room_state = val;
			if !joined && val != null:
				joined = true;
				has_joined.emit();

	func _init(channel: String) -> void:
		channel_name = channel;

	func leave() -> void:
		room_state = null;
		joined = false;
		for node in nodes: node.leave();

	func is_joined() -> void:
		if not joined: await has_joined;

class ParsedMessage extends RefCounted:
	## Parses all of the messages of IRC
	## Group1: Tags
	## Group2: Server / To User (Whisper) / From User (Chat)
	## Group3: Command
	## Group4: Channel / From User (Whisper)
	## Group5: Message / Payload
	var _irc_message_parser_regex = RegEx.create_from_string("(@.*? )?:(.*?)( [A-Z0-9]*)( #?.*?)?( :.*?)?$");

	var tags: String:
		get: return tags.trim_prefix("@");

	## Server / To User (Whisper) / From User (Chat)
	var server: String;

	var command: String:
		get: return command.strip_edges();

	## Channel / From User (Whisper)
	var channel: String:
		get: return channel.strip_edges().trim_prefix("#");

	## Message / Payload
	var message: String:
		get: return message.strip_edges().trim_prefix(":");

	func _init(msg: String) -> void:
		var matches = _irc_message_parser_regex.search(msg);
		if matches != null:
			tags = matches.get_string(1);
			server = matches.get_string(2);
			command = matches.get_string(3);
			channel = matches.get_string(4);
			message = matches.get_string(5);

class EmoteLocation extends RefCounted:
	var id : Variant;
	var start : int;
	var end : int;
	var sprite_frames: SpriteFrames;

	func _init(emote_id: Variant, start_idx: int, end_idx: int):
		self.id = emote_id;
		self.start = start_idx;
		self.end = end_idx;

	static func smaller(a : EmoteLocation, b : EmoteLocation):
		return a.start < b.start;

var auth: TwitchAuth;

func _init(twitch_auth : TwitchAuth) -> void:
	auth = twitch_auth;
	client.connection_state_changed.connect(_on_connection_state_changed);
	client.message_received.connect(_data_received);

## Starts the connection to IRC
func connect_to_irc() -> void:
	client.connect_to(TwitchSetting.irc_server_url);

## Called when the websocket state has changed
func _on_connection_state_changed(state: WebSocketPeer.State):
	var proc_frame = Engine.get_main_loop().process_frame as Signal;
	if(state == WebSocketPeer.STATE_OPEN):
		_login();
		_request_capabilities();
		_reconnect_to_channels();
		proc_frame.connect(_send_messages);
	else:
		for channel_name: String in channel_maps:
			channel_maps[channel_name].leave();
		if proc_frame.is_connected(_send_messages):
			proc_frame.disconnect(_send_messages);

## Sends the login message for authorization pupose and sets an username
func _login() -> void:
	client.send_text("PASS oauth:%s" % await auth.get_access_token());
	_send("NICK " + TwitchSetting.irc_username);

## Callback after a login try was made with the result value as parameter
func _on_login(success: bool):
	if success:
		_join_channels_on_connect();
	else: log.e("Can't connect");

func _request_capabilities() -> void:
	_send("CAP REQ :" + " ".join(TwitchSetting.irc_capabilities));

## Reconnect to all channels the bot was joined before (in case programatically joined channels)
func _reconnect_to_channels():
	for channel_name in channel_maps: join_channel(channel_name);

func _join_channels_on_connect():
	for channel_name: String in TwitchSetting.irc_connect_to_channel:
		var channel = join_channel(channel_name);
		var message: String = TwitchSetting.irc_login_message;
		if message != "":
			await channel.is_joined();
			chat(message, channel_name);

## Receives data on the websocket aka new messages
func _data_received(data : PackedByteArray) -> void:
	var messages : PackedStringArray = data.get_string_from_utf8().strip_edges(false).split("\r\n");
	for message: String in messages:
		# Reminder PONG messages is just different cant use match for it...
		if message.begins_with("PING"):
			_send("PONG :tmi.twitch.tv");
			continue;

		var parsed_message = ParsedMessage.new(message);
		_handle_message(parsed_message);

## Tries to send messages as long as the websocket is open
func _send_messages() -> void:
	if client.connection_state != WebSocketPeer.STATE_OPEN:
		log.e("Can't send message. Connection not open.")
		# Maybe buggy when the websocket got opened but not authorized yet
		# Can possible happen when we have a lot of load and a reconnect in the socket
		return;
	if not chat_queue.is_empty() && next_message <= Time.get_ticks_msec():
		var msg_to_send = chat_queue.pop_front();
		_send(msg_to_send);
		next_message = Time.get_ticks_msec() + TwitchSetting.irc_send_message_delay;

## Sends join channel message
func join_channel(channel_name : String) -> ChannelData:
	if channel_name == "":
		log.e("No channel is specified to join. The channel name can be set on the TwitchIrcChannel node.");
		return;

	var lower_channel = channel_name.to_lower();
	if not channel_maps.has(channel_name) || not channel_maps[channel_name].joined:
		chat_queue.append("JOIN #" + lower_channel);
		channel_maps[channel_name] = ChannelData.new(lower_channel);
	return channel_maps[channel_name];

## Sends leave channel message
func leave_channel(channel_name : String) -> void:
	if not channel_maps.has(channel_name):
		log.e("Can't leave %s channel cause we are not joined" % channel_name);
		return;

	var lower_channel : String = channel_name.to_lower();
	chat_queue.append("PART #" + lower_channel);
	channel_maps.erase(lower_channel);

## Sends a chat message to a channel. Defaults to the only connected channel.
## Channel should be always without '#'.
func chat(message : String, channel_name : String = ""):
	var channel_names : Array = channel_maps.keys();
	if channel_name == "" && channel_names.size() == 1:
		channel_name = channel_names[0];

	if channel_name == "":
		log.e("No channel is specified to send %s" % message);
		return;

	chat_queue.append("PRIVMSG #%s :%s\r\n" % [channel_name, message]);

	# Call it defered otherwise the response of the bot will be send before the command.
	_send_message_to_channel.call_deferred(channel_name, message);

## send the message of the bot to the channel for display purpose
func _send_message_to_channel(channel_name: String, message: String) -> void:
	if channel_maps.has(channel_name):
		var channel = channel_maps[channel_name] as ChannelData;
		var username = channel.user_state.display_name;
		# Convert the tags in a dirty way
		var tag = TwitchTags.PrivMsg.new(channel.user_state._raw);
		tag.room_id = channel.room_state.room_id;
		received_privmsg.emit(channel_name, username, message, tag);

## Sends a string message to Twitch.
func _send(text : String) -> void:
	client.send_text(text);
	log.i("< " + text.strip_edges(false));

## Handles all the messages. Tags can be empty when not requested via capabilities
func _handle_message(parsed_message : ParsedMessage) -> void:
	if parsed_message.command != "WHISPER":
		log.i("> [%15s] %s: %s" % [parsed_message.command, parsed_message.server, parsed_message.message]);

	match parsed_message.command:
		"001":
			log.i("Authentication successful.");
			_on_login(true);

		"CLEARCHAT":
			var clear_chat_tags = TwitchTags.ClearChat.new(parsed_message.tags);
			var user_to_ban_or_timeout = parsed_message.message;
			received_clearchat.emit(parsed_message.channel, parsed_message.message, clear_chat_tags);

		"CLEARMSG":
			var clear_msg_tags = TwitchTags.ClearMsg.new(parsed_message.tags);
			var message_to_remove = parsed_message.message;
			received_clearmsg.emit(parsed_message.channel, message_to_remove, clear_msg_tags);

		"GLOBALUSERSTATE":
			var global_userstate = TwitchTags.GlobalUserState.new(parsed_message.tags);
			received_global_userstate.emit(global_userstate)

		"HOSTTARGET":
			# Example: [-|<channel>] <number-of-viewers>
			var host_target_message = parsed_message.message.split(" ");
			var channel_being_hosted = host_target_message[0];
			var number_of_viewers = int(host_target_message[1]);
			var hosting_channel = parsed_message.channel;
			received_host_target.emit(channel_being_hosted, hosting_channel, number_of_viewers);

		"NOTICE":
			var notice_tags = TwitchTags.Notice.new(parsed_message.tags);
			var message = parsed_message.message;
			var handled := false;
			if not await _handle_cmd_notice(message):
				handled = true;
			received_notice.emit(parsed_message.channel, message, notice_tags, handled);

		"RECONNECT":
			received_reconnect.emit()

		"ROOMSTATE":
			var roomstate_tags = TwitchTags.Roomstate.new(parsed_message.tags);
			var channel_name = parsed_message.channel;
			received_roomstate.emit(channel_name, roomstate_tags)

			var channel = channel_maps[channel_name] as ChannelData;
			channel.room_state = roomstate_tags;

		"USERNOTICE":
			var user_notice_tags = TwitchTags.Usernotice.new(parsed_message.tags);
			received_usernotice.emit(parsed_message.channel, parsed_message.message, user_notice_tags);

		"USERSTATE":
			var userstate_tags = TwitchTags.Userstate.new(parsed_message.tags);
			var channel_name = parsed_message.channel;
			received_usernotice.emit(channel_name, userstate_tags);

			var channel = channel_maps[channel_name] as ChannelData;
			channel.user_state = userstate_tags;

		"WHISPER":
			var whisper_tags = TwitchTags.Whisper.new(parsed_message.tags);
			# Example: :<to-user>!<to-user>@<to-user>.tmi.twitch.tv
			var to_user = parsed_message.server;
			to_user = to_user.substr(0, to_user.find("!"))
			# Special case for whisper
			var from_user = parsed_message.channel;
			received_whisper.emit(from_user, to_user, parsed_message.message, whisper_tags);

		"PRIVMSG":
			var privmsg_tags = TwitchTags.PrivMsg.new(parsed_message.tags);
			var from_user = parsed_message.server;
			from_user = from_user.substr(0, from_user.find("!"))
			received_privmsg.emit(parsed_message.channel, from_user, parsed_message.message, privmsg_tags);

## Handles the update of rooms when joining the channel or a moderator
## updates it (Example :tmi.twitch.tv ROOMSTATE #bar)
func _handle_cmd_state(command: String, channel_name: String, tags: Dictionary) -> void:
	# right(-1) -> Remove the preceding # of the channel name
	channel_name = channel_name.right(-1).to_lower();
	if not channel_maps.has(channel_name):
		channel_maps[channel_name] = _create_channel(channel_name);

	var channel: TwitchIrcChannel = channel_maps[channel_name];
	channel.update_state(command, tags);
	#channel_data_updated.emit(channel_name, channel.data);
	log.i("Channel updated %s" % channel_name);

func _create_channel(channel_name: String) -> TwitchIrcChannel:
	var channel = TwitchIrcChannel.new();
	channel.channel_name = channel_name;
	channel_maps[channel_name] = channel;
	Engine.get_main_loop().root.add_child(channel);
	return channel;

## Tracks the channel.
func add_channel(channel: TwitchIrcChannel):
	var channel_name = channel.channel_name;
	if not channel_maps.has(channel_name):
		join_channel(channel_name);
		channel_maps[channel_name] = ChannelData.new(channel_name);
	var nodes = channel_maps[channel_name].nodes as Array[TwitchIrcChannel];
	nodes.append(channel);

## Remove the channel from getting tracked within the service
func remove_channel(channel: TwitchIrcChannel):
	var channel_name = channel.channel_name;
	var channel_data = channel_maps[channel_name] as ChannelData;
	channel_data.nodes.erase(channel);
	if channel_data.nodes.is_empty():
		leave_channel(channel_name);

func _handle_cmd_notice(info: String) -> bool:
	if info == "Login authentication failed" || info == "Login unsuccessful":
		log.e("Authentication failed.");
		_on_login(false);
		return true;
	elif info == "You don't have permission to perform that action":
		log.i("No permission. Attempting to obtain new token.");
		await auth.refresh_token();
		if await auth.is_authenticated():
			_login();
			return true;
		else:
			log.i("Please check if you have all required scopes.");
			client.close(1000, "Token became invalid.");
			return true;

	return false;
