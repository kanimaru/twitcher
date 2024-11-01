extends Node

## Command handler to add custom commands like !lurk
class_name TwitchCommandHandler

## Called when the command got received in the right format
signal command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray)

## Called when the command got received in the wrong format
signal received_invalid_command(from_username: String, info: TwitchCommandInfo, args: PackedStringArray);

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

@export var irc: TwitchIRC

var _commands: Dictionary = {}

## Registers a command on an object with a func to call, similar to connect(signal, instance, func).
func add_command(cmd_name : String, callable : Callable, min_args : int = 0, max_args : int = 0, permission_level : int = PermissionFlag.EVERYONE, where : int = WhereFlag.CHAT) -> void:
	if irc == null:
		push_error("Need IRC to add commands. Skip command %s" % cmd_name)
		return

	var command = TwitchCommand.create(irc, cmd_name, callable, min_args, max_args, permission_level, where)
	_commands[cmd_name] = command
	add_child(command)


## Removes a single command or alias.
func remove_command(cmd_name : String) -> void:
	if not _commands.has(cmd_name): return
	var command : TwitchCommand = _commands[cmd_name]
	if command.command == cmd_name:
		command.queue_free()
		for alias in command.aliases:
			_commands.erase(alias)
		_commands.erase(cmd_name)
		return
	command.aliases.erase(cmd_name)


## Removes a command and all associated aliases.
## FIXME Deprecated will be removed in future versions
func purge_command(cmd_name : String) -> void:
	remove_command(cmd_name)


## Add a command alias. The command specified in 'cmd_name' can now also be executed with the
## command specified in 'alias'.
func add_alias(cmd_name : String, alias : String) -> void:
	if not _commands.has(cmd_name): return
	var command = _commands[cmd_name]
	command.add_alias(alias)
	_commands[alias] = command


## Same as add_alias, but for multiple aliases at once.
func add_aliases(cmd_name : String, aliases : PackedStringArray) -> void:
	for alias in aliases:
		add_alias(cmd_name, alias);
