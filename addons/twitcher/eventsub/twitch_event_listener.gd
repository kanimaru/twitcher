@tool
@icon("../assets/event-icon.svg")
extends Node

## Listens to an event and publishes it as signal. Expects that the signal was
## already configured in the settings or manually subscribed.
class_name TwitchEventListener

@export var event_sub: TwitchEventsub:
	set(val):
		event_sub = val
		update_configuration_warnings()

@export var subscription: TwitchEventsubDefinition.Type:
	set(val):
		subscription = val
		update_configuration_warnings()

var subscription_definition: TwitchEventsubDefinition.Definition


## Called when the event got received
signal received(data: Dictionary)


func _ready() -> void:
	if event_sub == null: return
	if TwitchSetting.use_test_server:
		event_sub.event.connect(_on_received)
	event_sub.event.connect(_on_received)
	subscription_definition = TwitchEventsubDefinition.ALL[subscription]


func _on_received(type: String, data: Dictionary):
	if type == subscription_definition.value:
		received.emit(data)


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if event_sub == null:
		result.append("'EventSub' is missing")
	if subscription == null:
		result.append("'Subscription' is missing")
	return result
