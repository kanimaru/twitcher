@tool
extends Resource

## Defines howto subscribe to a eventsub subscription.
class_name TwitchEventsubConfig
static var _log: TwitchLogger = TwitchLogger.new("TwitchEventsubConfig")

## What do you want to subscribe
@export var type: TwitchEventsubDefinition.Type:
	set = _update_type

## How do you want to subscribe defined by `definition conditions`.
@export var condition: Dictionary = {}

var definition: TwitchEventsubDefinition:
	get(): return TwitchEventsubDefinition.ALL[type]

## Send from the server to identify the subscription for unsubscribing
var id: String

## Called when type changed
signal type_changed(new_type: TwitchEventsubDefinition.Type)


static func create(definition: TwitchEventsubDefinition, conditions: Dictionary) -> TwitchEventsubConfig:
	var config = TwitchEventsubConfig.new()
	config.type = definition.type
	config.condition = conditions
	for condition_name: StringName in definition.conditions:
		if not conditions.has(condition_name):
			_log.w("You miss probably follwing condition %s" % condition_name)
	return config


func _update_type(val: TwitchEventsubDefinition.Type) -> void:
	if type != val:
		type = val
		var definition: TwitchEventsubDefinition = TwitchEventsubDefinition.ALL[type]
		var new_condition: Dictionary = {}
		for condition_key: StringName in definition.conditions:
			new_condition[condition_key] = condition.get(condition_key, "")
		condition = new_condition
		type_changed.emit(val)


func _to_string() -> String:
	return "%s" % definition.get_readable_name()
