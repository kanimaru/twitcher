@tool
extends Resource

## Defines howto subscribe to a eventsub subscription.
class_name TwitchEventsubConfig

## What do you want to subscribe
@export var type: TwitchEventsubDefinition.Type:
	set = _update_type

## How do you want to subscribe defined by `definition conditions`.
@export var condition: Dictionary = {};

var definition: TwitchEventsubDefinition.Definition:
	get(): return TwitchEventsubDefinition.ALL[type]

## Send from the server to identify the subscription for unsubscribing
var id: String

## Called when type changed
signal type_changed(new_type: TwitchEventsubDefinition.Type)


func _update_type(val: TwitchEventsubDefinition.Type) -> void:
	if type != val:
		type = val
		var definition: TwitchEventsubDefinition.Definition = TwitchEventsubDefinition.ALL[type]
		var new_condition: Dictionary = {}
		for condition_key: StringName in definition.conditions:
			new_condition[condition_key] = condition.get(condition_key, "")
		condition = new_condition
		type_changed.emit(val)
