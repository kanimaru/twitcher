extends RefCounted

class_name TwitchCommandHandler

signal received_invalid_command(command, sender_data, cmd_data, arg_ary);

# Required permission to execute the command
enum PermissionFlag {
	EVERYONE = 0,
	VIP = 1,
	SUB = 2,
	MOD = 4,
	STREAMER = 8,
	MOD_STREAMER = 12, # Mods and the streamer
	NON_REGULAR = 15 # Everyone but regular viewers
}

# Where the command should be accepted
enum WhereFlag {
	CHAT = 1,
	WHISPER = 2,
	ANYWHERE = 3
}

# Messages starting with one of these symbols are handled as commands. '/' will be ignored, reserved by Twitch.
var command_prefixes : Array[String] = ["!"]
# Dictionary of commands, contains <command key> -> <Callable> entries.
var commands : Dictionary = {}

# Registers a command on an object with a func to call, similar to connect(signal, instance, func).
func add_command(cmd_name : String, callable : Callable, max_args : int = 0, min_args : int = 0, permission_level : int = PermissionFlag.EVERYONE, where : int = WhereFlag.CHAT) -> void:
	commands[cmd_name] = Command.new(callable, permission_level, max_args, min_args, where)

# Removes a single command or alias.
func remove_command(cmd_name : String) -> void:
	commands.erase(cmd_name)

# Removes a command and all associated aliases.
func purge_command(cmd_name : String) -> void:
	var to_remove = commands.get(cmd_name)
	if(to_remove):
		var remove_queue = []
		for command in commands.keys():
			if(commands[command].func_ref == to_remove.func_ref):
				remove_queue.append(command)
		for queued in remove_queue:
			commands.erase(queued)

# Add a command alias. The command specified in 'cmd_name' can now also be executed with the
# command specified in 'alias'.
func add_alias(cmd_name : String, alias : String) -> void:
	if(commands.has(cmd_name)):
		commands[alias] = commands.get(cmd_name)

# Same as add_alias, but for multiple aliases at once.
func add_aliases(cmd_name : String, aliases : PackedStringArray) -> void:
	for alias in aliases:
		add_alias(cmd_name, alias)

func handle_command(sender_data : TwitchSenderData, msg : String, whisper : bool = false) -> void:
	if(command_prefixes.has(msg.left(1))):
		msg = msg.right(-1)
		var split = msg.split(" ", true, 1)
		var command : String  = split[0]
		var cmd_data : Command = commands.get(command)
		if(cmd_data):
			if(whisper == true && cmd_data.where & WhereFlag.WHISPER != WhereFlag.WHISPER):
				return
			elif(whisper == false && cmd_data.where & WhereFlag.CHAT != WhereFlag.CHAT):
				return
			var arg_ary : PackedStringArray = PackedStringArray()
			if (split.size() > 1):
				arg_ary = split[1].split(" ")
				if(arg_ary.size() > cmd_data.max_args && cmd_data.max_args != -1 || arg_ary.size() < cmd_data.min_args):
					received_invalid_command.emit(command, sender_data, cmd_data, arg_ary);
					return
				if(cmd_data.permission_level != 0):
					var user_perm_flags = _get_perm_flag_from_tags(sender_data.tags)
					if(user_perm_flags & cmd_data.permission_level == 0):
						received_invalid_command.emit(command, sender_data, cmd_data, arg_ary);
						return
			if(arg_ary.size() == 0):
				if (cmd_data.min_args > 0):
					received_invalid_command.emit(command, sender_data, cmd_data, arg_ary);
					return
				cmd_data.func_ref.call(TwitchCommandInfo.new(sender_data, command, whisper))
			else:
				cmd_data.func_ref.call(TwitchCommandInfo.new(sender_data, command, whisper), arg_ary)

func _get_perm_flag_from_tags(tags : Dictionary) -> int:
	var flag = 0
	var entry = tags.get("badges")
	if(entry):
		for badge in entry.split(","):
			if(badge.begins_with("vip")):
				flag += PermissionFlag.VIP
			if(badge.begins_with("broadcaster")):
				flag += PermissionFlag.STREAMER
	entry = tags.get("mod")
	if(entry):
		if(entry == "1"):
			flag += PermissionFlag.MOD
	entry = tags.get("subscriber")
	if(entry):
		if(entry == "1"):
			flag += PermissionFlag.SUB
	return flag
