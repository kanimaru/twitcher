extends RefCounted

class_name TwitchIRC

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_IRC);

## Called when a chat message got received
signal chat_message(senderdata : TwitchSenderData, message : String);
## Called when a whisper message got received
signal whisper_message(sender_data : TwitchSenderData, message : String);
## Called when a channel receives an update
signal channel_data_updated(channel_name: String, tags: Dictionary);
## Callback all other messages that are not handled (mostly NOTICE messages)
signal unhandled_message(message: String, tags: Dictionary);

## Websocket client to communicate with the Twitch IRC server.
var client: WebsocketClient = WebsocketClient.new();

## Timestamp when the next message should be sent.
var next_message : int = Time.get_ticks_msec();

## Messages to send with an interval for disconnection protection
## see TwitchSettings.irc_send_message_delay.
var chat_queue : Array[String] = []

## All connected channels of the bot. Contains Key: channel_name -> Value: TwitchIrcChannel entries.
## See Requesting Twitch-specific capabilities at https://dev.twitch.tv/docs/irc/capabilities
var channel_maps : Dictionary = {}

## Returns everything between ! and @ example message looks like:
## :foo!foo@foo.tmi.twitch.tv PRIVMSG #bar :bleedPurple
var user_regex : RegEx = RegEx.create_from_string("!([\\w]*)@")

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
		if proc_frame.is_connected(_send_messages):
			proc_frame.disconnect(_send_messages);

## Sends the login message for authorization pupose and sets an username
func _login() -> void:
	client.send_text("PASS oauth:%s" % await auth.get_token());
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
	for channel_name in TwitchSetting.irc_connect_to_channel:
		var channel = join_channel(channel_name);
		var message: String = TwitchSetting.irc_login_message;
		if message != "":
			await channel.is_joined();
			channel.chat(message);

## Receives data on the websocket aka new messages
func _data_received(data : PackedByteArray) -> void:
	var messages : PackedStringArray = data.get_string_from_utf8().strip_edges(false).split("\r\n");
	var tags : Dictionary = {};
	for message in messages:
		# When the TAG Capability was requested,
		# the message contains the tags that starts with @
		if message.begins_with("@"):
			var msg : PackedStringArray = message.split(" ", false, 1);
			tags = _parse_tags(msg[0]);
			message = msg[1];
		log.i("> " + message);
		_handle_message(message, tags);

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

## Joins a new channel when not yet joined and return the channel.
func join_channel(channel : String) -> TwitchIrcChannel:
	var lower_channel : String = channel.to_lower()
	if channel_maps.has(lower_channel):
		return channel_maps[lower_channel];

	_send("JOIN #" + lower_channel)
	return _create_channel(lower_channel)

func leave_channel(channel : String) -> void:
	var lower_channel : String = channel.to_lower()
	_send("PART #" + lower_channel)

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

	if channel_maps.has(channel_name):
		var channel = channel_maps[channel_name] as TwitchIrcChannel;
		var user_name = channel.data['display-name'];
		var sender_data: TwitchSenderData = TwitchSenderData.new(user_name, channel, channel.data);
		channel.handle_message_received(sender_data, message);
		chat_message.emit(sender_data, message);

## Sends a string message to Twitch.
func _send(text : String) -> void:
	client.send_text(text);
	log.i("< " + text.strip_edges(false));

func _parse_tags(tags: String) -> Dictionary:
	var parsed_tags : Dictionary = {};
	for tag in tags.split(";"):
		var pair = tag.split("=");
		parsed_tags[pair[0]] = pair[1];
	return parsed_tags;

## Handles all the messages. Tags can be empty when not requested via capabilities
func _handle_message(received_message : String, tags : Dictionary) -> void:
	var message_parts : PackedStringArray = received_message.split(" ", true, 3);
	# Reminder PONG messages is just different cant use match for it...
	if message_parts[0] == "PING": _send("PONG :tmi.twitch.tv");

	var from := message_parts[0];
	var command := message_parts[1];
	match command:
		"NOTICE":
			var info := message_parts[3].right(-1);
			if not await _handle_cmd_notice(info):
				unhandled_message.emit(received_message, tags);
		"001":
			log.i("Authentication successful.");
			_on_login(true);
		"PRIVMSG": _handle_chat_message(from, message_parts, tags, chat_message);
		"WHISPER": _handle_chat_message(from, message_parts, tags, whisper_message);
		"USERSTATE", "ROOMSTATE":
			var channel_name = message_parts[2];
			_handle_cmd_state(command, channel_name, tags);
		_: unhandled_message.emit(received_message, tags);

## Handles the update of rooms when joining the channel or a moderator
## updates it (Example :tmi.twitch.tv ROOMSTATE #bar)
func _handle_cmd_state(command: String, channel_name: String, tags: Dictionary) -> void:
	# right(-1) -> Remove the preceding # of the channel name
	channel_name = channel_name.right(-1).to_lower();
	if not channel_maps.has(channel_name):
		channel_maps[channel_name] = _create_channel(channel_name);

	var channel: TwitchIrcChannel = channel_maps[channel_name];
	channel.update_state(command, tags);
	channel_data_updated.emit(channel_name, channel.data);
	log.i("Channel updated %s" % channel_name);

func _create_channel(channel_name: String) -> TwitchIrcChannel:
	var channel = TwitchIrcChannel.new(channel_name, self);
	channel_maps[channel_name] = channel;
	return channel;

## Handles chat messages from whisper and rooms.
## (Example: PRIVMSG #<channel name> :HeyGuys <3 PartyTime)
func _handle_chat_message(from: String, message_parts: Array[String], tags: Dictionary, output: Signal):
	# right(-1) -> Removes the # of the channel name
	var channel_name := message_parts[2].right(-1);
	# right(-1) -> Removes the : of the message
	var message := message_parts[3].right(-1);
	var user = user_regex.search(from).get_string(1);
	var channel = channel_maps[channel_name];
	var sender_data : TwitchSenderData = TwitchSenderData.new(user, channel, tags)
	output.emit(sender_data, message);

func _handle_cmd_notice(info: String) -> bool:
	if info == "Login authentication failed" || info == "Login unsuccessful":
		log.e("Authentication failed.");
		_on_login(false);
		return true;
	elif info == "You don't have permission to perform that action":
		log.i("No permission. Attempting to obtain new token.");
		await auth.refresh_token();
		if auth.is_authenticated():
			_login();
			return true;
		else:
			log.i("Please check if you have all required scopes.");
			client.close(1000, "Token became invalid.");
			return true;

	return false;
