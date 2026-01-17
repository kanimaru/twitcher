@icon("res://addons/twitcher/assets/command-icon.svg")
extends TwitchCommandBase

## A single command like !lurk 
class_name TwitchCommand

@export var command_prefixes : Array[String] = ["!"]:
	set(val):
		command_prefixes = val
		update_configuration_warnings()
		
## Optional names of commands
@export var aliases: Array[String]

## Minimal amount of argument 0 means no argument needed
@export var args_min: int = 0
## Max amount of arguments -1 means infinite
@export var args_max: int = -1


static func create(
		eventsub: TwitchEventsub,
		cmd_name: String,
		callable: Callable,
		min_args: int = 0,
		max_args: int = 0,
		permission_level: int = PermissionFlag.EVERYONE,
		where: int = WhereFlag.CHAT,
		allowed_users: Array[String] = [],
		listen_to_chatrooms: Array[String] = [],
		case_insensitive: bool = true) -> TwitchCommand:
	var command := TwitchCommand.new()
	command.eventsub = eventsub
	command.command = cmd_name
	command.command_received.connect(callable)
	command.args_min = min_args
	command.args_max = max_args
	command.permission_level = permission_level
	command.where = where
	command.allowed_users = allowed_users
	command.listen_to_chatrooms = listen_to_chatrooms
	command.case_insensitive = case_insensitive
	return command


func _enter_tree() -> void:
	super._enter_tree()
	ALL_COMMANDS.append(self)
	
	
func _exit_tree() -> void:
	super._exit_tree()
	ALL_COMMANDS.erase(self)


func add_alias(alias: String) -> void:
	aliases.append(alias)
	

func _should_handle(info: TwitchCommandInfo) -> bool:
	if not super._should_handle(info): return false
	var message: String = info.text_message
	if not command_prefixes.has(message.left(1)): return false

	# remove the command symbol in front
	message = message.right(-1)
	var split: PackedStringArray = message.split(" ", true, 1)
	var current_command: String = split[0] 
	var alias_compare_function: Callable = func(cmd) -> bool:
		if case_insensitive:
			return current_command.nocasecmp_to(cmd) == 0
		else:
			return current_command.casecmp_to(cmd) == 0
	
	var is_alias: bool = aliases.any(alias_compare_function)
	var is_command: bool = alias_compare_function.call(command)

	return is_command || is_alias


func _handle_command(info: TwitchCommandInfo) -> void:
	var message: String = info.text_message
	# remove the command symbol in front
	message = message.right(-1)
	var cmd_msg: PackedStringArray = message.split(" ", true, 1)
	
	var command: String = cmd_msg[0]
	if not _can_handle_command(info):
		return
		
	var arguments: PackedStringArray = info.arguments
	# Handle Argument parsing
	if cmd_msg.size() > 1:
		arguments.append_array(cmd_msg[1].split(" ", false))
		var to_less_arguments: bool = arguments.size() < args_min
		var to_much_arguments: bool = arguments.size() > args_max
		if to_much_arguments && args_max != -1 || to_less_arguments:
			received_invalid_command.emit(info.username, info, arguments)
			return
	if arguments.size() == 0 && args_min > 0:
		received_invalid_command.emit(info.username, info, arguments)
		return

	# Executing the command
	if arguments.size() == 0:
		var empty_args: Array[String] = []
		if args_max > 0:
			command_received.emit(info.username, info, empty_args)
		else:
			command_received.emit(info.username, info, empty_args)
	else:
		command_received.emit(info.username, info, arguments)


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	for prefix: String in command_prefixes:
		if prefix.length() > 1:
			result.append("TwitchCommand supports only 1 character for command prefix. (%s)" % [prefix])
	return result


func _to_string() -> String:
	return "%s%s" % [command_prefixes[0], command]
