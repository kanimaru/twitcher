extends RefCounted

# Original from https://github.com/issork/gift slightly modified

## Command handler to add custom commands like !lurk
class_name TwitchCommandHandler

## Send when an invalid command was typed
signal received_invalid_command(command: String, channel_name: String, username: String, cmd_data: TwitchCommand, arg_array: PackedStringArray, tag: Variant);

## Required permission to execute the command
enum PermissionFlag {
	EVERYONE = 0,
	VIP = 1,
	SUB = 2,
	MOD = 4,
	STREAMER = 8,
	MOD_STREAMER = 12, # Mods and the streamer
	NON_REGULAR = 15 # Everyone but regular viewers
}

## Where the command should be accepted
enum WhereFlag {
	CHAT = 1,
	WHISPER = 2,
	ANYWHERE = 3
}

## Messages starting with one of these symbols are handled as commands. '/' will be ignored, reserved by Twitch.
var command_prefixes : Array[String] = ["!"];
## Dictionary of commands, contains <command key> -> <Callable> entries.
var commands : Dictionary = {};

## Registers a command on an object with a func to call, similar to connect(signal, instance, func).
func add_command(cmd_name : String, callable : Callable, min_args : int = 0, max_args : int = 0, permission_level : int = PermissionFlag.EVERYONE, where : int = WhereFlag.CHAT) -> void:
	commands[cmd_name] = TwitchCommand.new(callable, permission_level, min_args, max_args, where);

## Removes a single command or alias.
func remove_command(cmd_name : String) -> void:
	commands.erase(cmd_name);

## Removes a command and all associated aliases.
func purge_command(cmd_name : String) -> void:
	var to_remove = commands.get(cmd_name);
	if(to_remove):
		var remove_queue = [];
		for command in commands.keys():
			if(commands[command].func_ref == to_remove.func_ref):
				remove_queue.append(command);
		for queued in remove_queue:
			commands.erase(queued);

## Add a command alias. The command specified in 'cmd_name' can now also be executed with the
## command specified in 'alias'.
func add_alias(cmd_name : String, alias : String) -> void:
	if(commands.has(cmd_name)):
		commands[alias] = commands.get(cmd_name);

## Same as add_alias, but for multiple aliases at once.
func add_aliases(cmd_name : String, aliases : PackedStringArray) -> void:
	for alias in aliases:
		add_alias(cmd_name, alias);

func _get_command(message: String) -> TwitchCommand:
	if(not command_prefixes.has(message.left(1))): return
	# remove the command symbol in front
	message = message.right(-1);
	var split = message.split(" ", true, 1);

	var command : String  = split[0];
	if(commands.has(command)):
		return commands.get(command);
	return null;

## Handles all the commands that will be send in chat rooms
func handle_chat_command(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg) -> void:
	var command = _get_command(message);
	if(command == null): return
	if(command.where & WhereFlag.CHAT != WhereFlag.CHAT): return;
	_handle_command(command, message, channel_name, username, tags);

## Handles all the commands that will be send in whisper message
func handle_whisper_command(from_user: String, to_user: String, message: String, tags: TwitchTags.Whisper) -> void:
	var command = _get_command(message);
	if(command == null): return
	if(command.where & WhereFlag.WHISPER != WhereFlag.WHISPER): return;
	_handle_command(command, message, "", from_user, tags);

func _handle_command(command: TwitchCommand, raw_message: String, channel_name: String, username: String, tags: Variant) -> void:
	# remove the command symbol in front
	raw_message = raw_message.right(-1);
	var cmd_msg = raw_message.split(" ", true, 1);
	var command_name = cmd_msg[0];
	var message = "";
	var arg_array : PackedStringArray = PackedStringArray();
	if (cmd_msg.size() > 1):
		message = cmd_msg[1];
		arg_array = message.split(" ");
		var to_less_arguments = arg_array.size() < command.min_arguments;
		var to_much_arguments = arg_array.size() > command.max_arguments;
		if(to_much_arguments && command.max_arguments != -1 || to_less_arguments):
			received_invalid_command.emit(command_name, channel_name, username, commands, arg_array, tags);
			return
		var premission_required = command.permission_level != 0
		if(premission_required):
			var user_perm_flags = _get_perm_flag_from_tags(tags)
			if(user_perm_flags & command.permission_level == 0):
				received_invalid_command.emit(command_name, channel_name, username, commands, arg_array, tags);
				return
	if(arg_array.size() == 0):
		if (command.min_arguments > 0):
			received_invalid_command.emit(command_name, channel_name, username, commands, arg_array, tags);
			return
		var info = TwitchCommandInfo.new(command_name, command, message, channel_name, username, tags);
		if (command.max_arguments > 0):
			command.function_reference.call(info, [] as Array[String])
		else:
			command.function_reference.call(info)
	else:
		command.function_reference.call(TwitchCommandInfo.new(command_name, command, message, channel_name, username, tags), arg_array)

func _get_perm_flag_from_tags(tags : Dictionary) -> int:
	var flag = 0
	var badges = tags.get("badges")
	if(badges != null):
		for badge in badges.split(","):
			if(badge.begins_with("vip")):
				flag += PermissionFlag.VIP
			if(badge.begins_with("broadcaster")):
				flag += PermissionFlag.STREAMER
	if(tags.get("mod", "0") == "1"):
		flag += PermissionFlag.MOD
	if(tags.get("subscriber", "0") == "1"):
		flag += PermissionFlag.SUB
	return flag
