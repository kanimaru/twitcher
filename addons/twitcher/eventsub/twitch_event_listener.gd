@icon("../assets/event-icon.svg")
extends Node

## Listens to an event and publishes it as signal. Expects that the signal was
## already configured in the settings or manually subscribed.
class_name TwitchEventListener

## Called when the event got received
signal received(data: Dictionary)

@export var event_sub: TwitchEventsub
@export var subscription: TwitchEventsubDefinition.Type;
var subscription_name: String;

func _ready() -> void:
	assert(subscription != null);
	if TwitchSetting.use_test_server:
		event_sub.event.connect(_on_received)
	event_sub.event.connect(_on_received);
	var all_subs: Array[TwitchEventsubDefinition.Definition] = TwitchEventsubDefinition.ALL.values();
	subscription_name = all_subs[subscription].value;

func _on_received(type: String, data: Dictionary):
	if type == subscription_name:
		received.emit(data);
