@tool
@icon("../assets/event-icon.svg")
extends Twitcher

## Listens to an event and publishes it as signal.
## Usage for easy access of events on test and normal eventsub makes it more obvious what a scene
## is listening before diving in the code.
##
## The conditions that are needed are defined by the selected [member subscription]. When they are
## filled this node subscribes on its own in case the [TwitchEventsub] doesn't have a fitting
## subscription yet. Otherwise the subscription has to be configured on the [TwitchEventsub] or
## made manually.
class_name TwitchEventListener
static var _log : TwitchLogger = TwitchLogger.new("TwitchEventListener")

## Eventsub to listen the events. (Can be empty will automatically look for first [TwitchEventsub] in the scene tree)
@export var eventsub: TwitchEventsub:
	set = _update_eventsub

## The subscription to listen for. Determines which conditions are needed.
@export var subscription: TwitchEventsubDefinition.Type:
	set = _update_subscription

## Conditions to subscribe with. Which conditions are available is defined by the
## [member subscription]. Only used when the [TwitchEventsub] has no fitting subscription yet.
@export var condition: Dictionary = {}:
	set = _update_condition

## Subscribes on ready when the [TwitchEventsub] has no fitting subscription and the
## [member condition] is completely filled.
@export var ensure_subscription_on_ready: bool = true

## Definition of the currently selected [member subscription]
var definition: TwitchEventsubDefinition:
	get(): return TwitchEventsubDefinition.ALL[subscription]

## Definition of the currently selected [member subscription]
## [i]Deprecated: use [member definition] instead[/i]
var subscription_definition: TwitchEventsubDefinition:
	get(): return definition

## Subscription that got created by this node. Null when it didn't subscribe on its own.
var _own_subscription: TwitchEventsubConfig


## Called when the event got received
signal received(data: Dictionary)
## Called when the event got received, with the eventsub data parsed into an object
signal typed_data_received(data: Variant)


func _ready() -> void:
	# The setter connects to the eventsub
	if eventsub == null: eventsub = TwitchEventsub.instance
	if Engine.is_editor_hint(): return
	if ensure_subscription_on_ready: ensure_subscription()


func _enter_tree() -> void:
	start_listening()


func _exit_tree() -> void:
	stop_listening()


func start_listening() -> void:
	if eventsub == null: return
	_log.d("start listening %s" % definition.get_readable_name())
	if not eventsub.event_received.is_connected(_on_received):
		eventsub.event_received.connect(_on_received)
	if not eventsub.subscription_failed.is_connected(_on_subscription_failed):
		eventsub.subscription_failed.connect(_on_subscription_failed)


func stop_listening() -> void:
	if eventsub == null: return
	_log.d("stop listening %s" % definition.get_readable_name())
	if eventsub.event_received.is_connected(_on_received):
		eventsub.event_received.disconnect(_on_received)
	if eventsub.subscription_failed.is_connected(_on_subscription_failed):
		eventsub.subscription_failed.disconnect(_on_subscription_failed)


## Ensures that the [TwitchEventsub] has a subscription that this node can listen to.
## Subscribes on its own when the conditions are filled. Logs an error when there is no
## subscription and none could be created.
func ensure_subscription() -> void:
	if eventsub == null:
		_log.e("Can't listen to '%s'. No TwitchEventsub found. Assign one or add a TwitchEventsub to the scene tree." % definition.get_readable_name())
		return

	var conditions: Dictionary = get_conditions()
	if _find_subscription(conditions) != null:
		_log.d("Subscription for '%s' exists already." % definition.get_readable_name())
		return

	var missing_conditions: Array[StringName] = get_missing_conditions()
	if not missing_conditions.is_empty():
		if not eventsub.get_subscription_by_type(subscription).is_empty():
			# Subscribed with other conditions. Someone configured it on purpose, so it's fine.
			_log.d("Subscription for '%s' is configured with other conditions." % definition.get_readable_name())
			return
		_log.e("Can't listen to '%s'. The TwitchEventsub has no subscription for it and this listener can't subscribe on its own, cause following conditions are missing: [%s]" % [definition.get_readable_name(), ", ".join(missing_conditions)])
		return

	_subscribe(conditions)


## All conditions of the [member subscription] that have no value yet.
func get_missing_conditions() -> Array[StringName]:
	var result: Array[StringName] = []
	var conditions: Dictionary = get_conditions()
	for condition_key: StringName in definition.conditions:
		if str(conditions.get(condition_key, "")).is_empty():
			result.append(condition_key)
	return result


## Conditions that are used to subscribe. Resolves the users that got selected within the editor.
func get_conditions() -> Dictionary:
	var result: Dictionary = {}
	for condition_key: StringName in definition.conditions:
		if has_meta(condition_key + "_user"):
			var user: TwitchUser = get_meta(condition_key + "_user")
			result[condition_key] = user.id
		else:
			result[condition_key] = str(condition.get(condition_key, ""))
	return result


func _subscribe(conditions: Dictionary) -> void:
	_log.i("No subscription for '%s' found. Subscribing with %s." % [definition.get_readable_name(), conditions])
	_own_subscription = TwitchEventsubConfig.create(definition, conditions)
	eventsub.subscribe(_own_subscription)


## Searches a subscription on the eventsub that fits to the given conditions. Returns the config when found or null.
func _find_subscription(conditions: Dictionary) -> TwitchEventsubConfig:
	for config: TwitchEventsubConfig in eventsub.get_subscription_by_type(subscription):
		if _normalize_conditions(config.get_conditions()) == _normalize_conditions(conditions):
			return config
	return null


## Brings the conditions into a comparable form. (Keys can be String or StringName)
func _normalize_conditions(conditions: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in conditions:
		result[str(key)] = str(conditions[key])
	return result


func _update_eventsub(val: TwitchEventsub) -> void:
	stop_listening()
	eventsub = val
	update_configuration_warnings()
	start_listening()


func _update_subscription(val: TwitchEventsubDefinition.Type) -> void:
	if subscription == val: return
	subscription = val
	# Keep the values of the conditions that the new subscription needs too
	var new_condition: Dictionary = {}
	for condition_key: StringName in definition.conditions:
		new_condition[condition_key] = condition.get(condition_key, "")
	condition = new_condition
	update_configuration_warnings()
	notify_property_list_changed()


func _update_condition(val: Dictionary) -> void:
	condition = val
	update_configuration_warnings()


func _on_received(event: TwitchEventsub.Event) -> void:
	if event.type == definition:
		var event_conditions: Dictionary = event.get_condition()
		# Has special conditions
		if _own_subscription and _normalize_conditions(condition) != _normalize_conditions(event_conditions):
			return

		# Need for backward compatibility
		received.emit(event.data)
		typed_data_received.emit(event.typed_data)


func _on_subscription_failed(failed_subscription: TwitchEventsubConfig, reason: String) -> void:
	if failed_subscription != _own_subscription: return
	_log.e("Can't listen to '%s'. The subscription failed: %s" % [definition.get_readable_name(), reason])


func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []
	var missing_conditions: Array[StringName] = get_missing_conditions()
	if not missing_conditions.is_empty():
		result.append("Conditions [%s] are empty. This node can only receive events when the TwitchEventsub is already subscribed to '%s'." % [", ".join(missing_conditions), definition.get_readable_name()])
	return result
