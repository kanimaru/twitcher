@tool
@icon("../assets/event-icon.svg")
extends Node

## Listens to an event and publishes it as signal.
## Usage for easy access of events on test and normal eventsub makes it more obvious what a scene
## is listening before diving in the code.

## [b]Expects that the signal was already configured in the eventsub or manually subscribed[/b]
class_name TwitchEventListener
static var _log : TwitchLogger = TwitchLogger.new("TwitchEventListener")

@export var eventsub: TwitchEventsub:
	set = _update_eventsub

@export var subscription: TwitchEventsubDefinition.Type:
	set(val):
		subscription = val
		subscription_definition = TwitchEventsubDefinition.ALL[subscription]
		update_configuration_warnings()

var subscription_definition: TwitchEventsubDefinition


## Called when the event got received
signal received(data: Dictionary)


func _ready() -> void:
	_update_eventsub(eventsub)


func _enter_tree() -> void:
	start_listening()


func _exit_tree() -> void:
	stop_listening()


func start_listening() -> void:
	_log.d("start listening %s" % subscription_definition.get_readable_name())
	if eventsub != null && not eventsub.event.is_connected(_on_received):
		if eventsub.use_test_server:
			eventsub.event.connect(_on_received)
		eventsub.event.connect(_on_received)


func stop_listening() -> void:
	_log.d("stop listening %s" % subscription_definition.get_readable_name())
	if eventsub != null && eventsub.event.is_connected(_on_received):
		if eventsub.use_test_server:
			eventsub.event.disconnect(_on_received)
		eventsub.event.disconnect(_on_received)


func _update_eventsub(val: TwitchEventsub):
	stop_listening()
	eventsub = val
	update_configuration_warnings()
	if val == null: return
	start_listening()


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
