@tool
extends RefCounted

## Logger class that can be enabled and disabled.
class_name TwitchLogger

## Name of the logger that will be shown in the logs
var context_name: String;
var suffix: String;
var enabled : bool;
var debug: bool;

func _init(ctx_name: String) -> void:
	context_name = ctx_name;
	TwitchLoggerManager.register(self);

func is_enabled() -> bool:
	return enabled;

func set_enabled(status: bool) -> void:
	enabled = status;

func set_suffix(s: String) -> void:
	suffix = "-" + s;

## log a message on info level
func i(text: String):
	if is_enabled(): print("[%s%s] %s" % [context_name, suffix, text]);

## log a message on error level
func e(text: String):
	if is_enabled(): printerr("[%s%s] %s" % [context_name, suffix, text]);

func d(text: String):
	if is_enabled() && debug: print("[%s%s] %s" % [context_name, suffix, text]);
