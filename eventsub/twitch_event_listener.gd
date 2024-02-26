@icon("../assets/event-icon.svg")
extends Node

## Listens to an event and publishes it as signal. Expects that the signal was
## already configured in the settings or manually subscribed.
class_name TwitchEventListener

## Called when the event got received
signal received(data: Dictionary)

@export var subscription: TwitchSubscriptions.Subscriptions;
var subscription_name: String;

func _ready() -> void:
	assert(subscription != null);
	var event_sub = TwitchService.eventsub as TwitchEventsub;
	event_sub.event.connect(_on_received);
	var all_subs = TwitchSubscriptions.get_all();
	subscription_name = all_subs[subscription].value;

func _on_received(type: String, data: Dictionary):
	if type == subscription_name:
		received.emit(data);
