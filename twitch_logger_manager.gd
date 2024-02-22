@tool
extends RefCounted

## Couples the logger to the enabled state of the settings.
class_name TwitchLoggerManager

static var log_registry : Dictionary = {};

## Register the logger and set the enabled state
static func register(logger: TwitchLogger) -> void:
	log_registry[logger.context_name] = logger;
	logger.set_enabled(TwitchSetting.is_log_enabled(logger.context_name));
