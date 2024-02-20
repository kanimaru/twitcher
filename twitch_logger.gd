extends RefCounted

class_name TwitchLogger

var context_name: String;
var suffix: String;

func _init(ctx_name: String) -> void:
	context_name = ctx_name;

func is_enabled() -> bool:
	return TwitchSetting.is_log_enabled(context_name);

func set_suffix(s: String) -> void:
	suffix = "-" + s;

func i(text: String):
	if is_enabled(): print("[%s%s] %s" % [context_name, suffix, text]);

func e(text: String):
	if is_enabled(): printerr("[%s%s] %s" % [context_name, suffix, text]);
