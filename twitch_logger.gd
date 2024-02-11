extends RefCounted

class_name TwitchLogger

var context_name: String;

func _init(ctx_name: String) -> void:
	context_name = ctx_name;

func is_enabled() -> bool:
	return TwitchSetting.is_log_enabled(context_name);

func i(text: String):
	if is_enabled(): print("[%s] %s" % context_name, text);

func e(text: String):
	if is_enabled(): printerr("[%s] %s" % context_name, text);
