@tool
extends Twitcher

## Helps to listen for polls running on Twitch streams. 
##
## This Listener exposes multiple [Signal]s to connect to. Each [Signal] has a purpose in the life cycle of a Poll.[br]
##
## - [signal poll_begin]: A poll was successfully started/created on stream.[br]
## - [signal poll_progress]: A vote was casted on the poll.[br]
## - [signal poll_completed]: A poll has ended normaly. Poll is still shown on stream.[br] 
## - [signal poll_terminated]: A poll has ended early (before the duration has run out). Poll is still shown on stream.[br]
## - [signal poll_archived]: A poll was either (terminated or completed) and is not shown on stream anymore.
class_name TwitchPollListener
static var _log: TwitchLogger = TwitchLogger.new("TwitchPollListener")


## The [TwitchEventSub] for subscribing. If left empty, the Node attempts to fetch the [TwitchEventsub] itself.
@export var eventsub: TwitchEventsub
## The [TwitchAPI] for API calls. If left empty, the Node attempts to fetch the [TwitchAPI] itself.
@export var api: TwitchAPI
## Should the node automatically subscribe to the needed eventsubs in the ready function. 
@export var ensure_subscriptions_on_ready: bool = true
## The Broadcaster User. If left empty the Node will attempt to fetch it from [method TwitchService.get_current_user_via_api]
@export var broadcaster: TwitchUser


## Emits the raw json response from the [enum TwitchEventsubDefinition.Type]s [member TwitchEventsubDefinition.CHANNEL_POLL_BEGIN] , [member TwitchEventsubDefinition.CHANNEL_POLL_PROGRESS] and [member TwitchEventsubDefinition.CHANNEL_POLL_END].
signal poll_json(poll_json: Dictionary)
## Emits a [TwitchPoll] object when a poll is created/begins.
signal poll_begin(poll: TwitchPoll)
## Emits a [TwitchPoll] object when a poll has progressed.
signal poll_progress(poll: TwitchPoll)
## Emits a [TwitchPoll] object when a poll is completed.
signal poll_completed(poll: TwitchPoll)
## Emits a [TwitchPoll] object when a poll is terminated.
signal poll_terminated(poll: TwitchPoll)
## Emits a [TwitchPoll] object when a poll is archived.
signal poll_archived(poll: TwitchPoll)


func _ready() -> void:
	if eventsub == null: eventsub = TwitchEventsub.instance
	if api == null: api = TwitchAPI.instance
	if not broadcaster: broadcaster = await TwitchService.get_current_user_via_api(api)
	
	if not Engine.is_editor_hint() && ensure_subscriptions_on_ready:
		_log.d("Ensuring subscription configuration on TwitchEventsub.")
		ensure_subscriptions()
	
	if eventsub != null: 
		_log.d("Connecting to eventsub!")
		eventsub.event.connect(_on_event)
	else:
		_log.e("Eventsub missing can't connect TwitchPollListener!")


## Ensures the selected [TwitchEventSub] is subscribed to the right [TwitchEventsubDefinition.Type].
func ensure_subscriptions() -> void:
	var begin_subscription: Array[TwitchEventsubConfig] = eventsub.get_subscription_by_type(TwitchEventsubDefinition.Type.CHANNEL_POLL_BEGIN)
	var end_subscription: Array[TwitchEventsubConfig] = eventsub.get_subscription_by_type(TwitchEventsubDefinition.Type.CHANNEL_POLL_END)
	var progress_subscription: Array[TwitchEventsubConfig] = eventsub.get_subscription_by_type(TwitchEventsubDefinition.Type.CHANNEL_POLL_PROGRESS)
	var config_dict: Dictionary = { "broadcaster_user_id": broadcaster.id }
	if begin_subscription.is_empty():
		var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_POLL_BEGIN, config_dict)
		eventsub.subscribe(config)
		_log.d("No subscription for Poll Begin found. Subscribing!")
	if end_subscription.is_empty():
		var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_POLL_END, config_dict)
		eventsub.subscribe(config)
		_log.d("No subscription for Poll End found. Subscribing!")
	if progress_subscription.is_empty():
		var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_POLL_PROGRESS, config_dict)
		eventsub.subscribe(config)
		_log.d("No subscription for Poll Progress found. Subscribing!")
		

## Receives and handles the Signal from the selected [TwitchEventSub].
func _on_event(type: StringName, data: Dictionary) -> void:
	if type == TwitchEventsubDefinition.CHANNEL_POLL_BEGIN.value:
		var poll: TwitchPoll = TwitchPoll.from_json(data)
		_log.i("Received Beginn of Poll: %s" % [poll.title])
		poll_json.emit(data)
		poll_begin.emit(poll)
	elif type == TwitchEventsubDefinition.CHANNEL_POLL_PROGRESS.value:
		var poll: TwitchPoll = TwitchPoll.from_json(data)
		_log.d("Received Progress of Poll: %s" % [poll.title])
		poll_json.emit(data)
		poll_progress.emit(poll)
	elif type == TwitchEventsubDefinition.CHANNEL_POLL_END.value:
		var poll: TwitchPoll = TwitchPoll.from_json(data)
		if poll.status == "completed":
			_log.i("Received Completion of Poll: %s" % [poll.title])
			poll_completed.emit(poll)
		elif poll.status == "terminated":
			_log.i("Received Termination of Poll: %s" % [poll.title])
			poll_terminated.emit(poll)
		elif poll.status == "archived":
			_log.i("Received Archived of Poll: %s" % [poll.title])
			poll_archived.emit(poll)
		poll_json.emit(data)
