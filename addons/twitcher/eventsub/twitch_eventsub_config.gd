@tool
extends Resource

## Defines howto subscribe to a eventsub subscription.
class_name TwitchEventsubConfig
static var _log: TwitchLogger = TwitchLogger.new("TwitchEventsubConfig")
const TwitchEditorSettings = preload("uid://kqcukq2xqnuf")

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
			_log.i("You miss probably following condition %s" % condition_name)
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
		notify_property_list_changed()


func _to_string() -> String:
	return "%s" % definition.get_readable_name()


func get_conditions() -> Dictionary:
	var result: Dictionary = {}
	for condition_key: StringName in definition.conditions:
		if has_meta(condition_key + "_user"):
			var user: TwitchUser = get_meta(condition_key + "_user")
			result[condition_key] = user.id
			continue
		# Not every listed condition is required, and some are mutually exclusive (channel.raid takes
		# either from_broadcaster_user_id or to_broadcaster_user_id, never both). Sending the unused
		# key with an empty value makes Twitch reject the subscription, so leave blanks out.
		var raw: Variant = condition.get(condition_key, null)
		if raw == null: continue
		var value: String = str(raw)
		if value.is_empty(): continue
		result[condition_key] = value
	return result
