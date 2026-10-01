extends TwitcherTest
## Unit tests for [LogfamiFixedClock] and the default [LogfamiClock].


func test_fixed_clock_returns_its_start_values() -> void:
	var clock: LogfamiFixedClock = LogfamiFixedClock.new(1_000, 20)
	assert_eq(clock.now_unix_ms(), 1_000)
	assert_eq(clock.ticks_msec(), 20)


func test_advance_moves_both_values() -> void:
	var clock: LogfamiFixedClock = LogfamiFixedClock.new(1_000, 20)
	clock.advance(5)
	assert_eq(clock.now_unix_ms(), 1_005)
	assert_eq(clock.ticks_msec(), 25)


func test_system_clock_is_close_to_now() -> void:
	var clock: LogfamiClock = LogfamiClock.new()
	var now_ms: int = int(Time.get_unix_time_from_system() * 1000.0)
	assert_almost_eq(clock.now_unix_ms(), now_ms, 1000)
	assert_almost_eq(clock.ticks_msec(), Time.get_ticks_msec(), 1000)
