@tool
@icon("../assets/event-icon.svg")
extends Node

## Listens to an event and publishes it as signal. Expects that the signal was
## already configured in the settings or manually subscribed.
class_name TwitchEventListener

@export var eventsub: TwitchEventsub:
	set = _update_eventsub


@export var subscription: TwitchEventsubDefinition.Type:
	set(val):
		subscription = val
		update_configuration_warnings()

var subscription_definition: TwitchEventsubDefinition.Definition


## Called when the event got received
signal received(data: Dictionary)


func _ready() -> void:
	_update_eventsub(eventsub)
	subscription_definition = TwitchEventsubDefinition.ALL[subscription]


func _update_eventsub(val: TwitchEventsub):
	if eventsub != null:
		if TwitchSetting.use_test_server:
			eventsub.event.disconnect(_on_received)
		eventsub.event.disconnect(_on_received)

	eventsub = val
	print("Eventsub: ", val)
	update_configuration_warnings()
	if val == null: return

	if TwitchSetting.use_test_server:
		eventsub.event.connect(_on_received)
	eventsub.event.connect(_on_received)


func _on_received(type: String, data: Dictionary):
	if type == subscription_definition.value:
		received.emit(data)


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	if eventsub == null:
		result.append("'EventSub' is missing")
	if subscription == null:
		result.append("'Subscription' is missing")
	return result
