## Tests for [TwitchRedeemListener].
extends TwitcherTest


var _capture: LogCapture


func before_each() -> void:
	super()
	TwitchLoggerManager.clear_handlers()
	_capture = LogCapture.new()
	TwitchLoggerManager.add_handler(_capture.handle, LogfamiLevel.Severity.ERROR)


## Can only fail through a runtime error: before the guard, _ready called
## connect on a null eventsub.
func test_ready_without_eventsub_logs_an_error_instead_of_crashing() -> void:
	TwitchEventsub.instance = null
	var listener: TwitchRedeemListener = TwitchRedeemListener.new()
	listener.ensure_subscriptions_on_ready = false

	add_child_autofree(listener)

	assert_null(listener.eventsub)
	assert_has(_capture.bodies(), "Eventsub missing can't connect TwitchRedeemListener!")
