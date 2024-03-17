extends RefCounted

## The definition of a twitch command.
class_name TwitchCommand

var function_reference : Callable
var permission_level : int
var max_arguments : int
var min_arguments : int
var where : int

func _init(function_ref : Callable, pemission_lvl : int, min_args : int, max_args : int, whr : int):
	function_reference = function_ref
	permission_level = pemission_lvl
	max_arguments = max_args
	min_arguments = min_args
	where = whr
