@tool
extends RefCounted

## Couples the logger to the enabled state of the settings.
class_name TwitchLoggerManager

static var log_registry : Dictionary = {}

## Register the logger and set the enabled state
static func register(logger: TwitchLogger) -> void:
	log_registry[logger.context_name] = logger
	var property = TwitchProperty.new("twitcher/logs/%s" % logger.context_name, "off").as_select(["off", "info", "debug"])
	if property.get_val() != "off":
		logger.set_enabled(true)
	if property.get_val() == "debug":
		logger.debug = true
