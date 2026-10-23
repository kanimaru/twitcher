## Tests for [TwitchSeenMessages].
##
## Time is passed in explicitly, so expiry is tested without waiting.
extends TwitcherTest

const WINDOW: int = 1000


func _make(maximum: int = 10000) -> TwitchSeenMessages:
	return TwitchSeenMessages.new(WINDOW, maximum)


func test_a_new_id_is_remembered() -> void:
	var seen: TwitchSeenMessages = _make()

	assert_true(seen.remember("a", 0), "a new id is no duplicate")
	assert_true(seen.has("a"))


func test_a_remembered_id_is_a_duplicate() -> void:
	var seen: TwitchSeenMessages = _make()
	seen.remember("a", 0)

	assert_false(seen.remember("a", 10), "the same id again is a duplicate")
	assert_eq(seen.size(), 1)


func test_an_id_is_kept_for_the_whole_window() -> void:
	var seen: TwitchSeenMessages = _make()
	seen.remember("a", 0)

	seen.expire(WINDOW)

	assert_true(seen.has("a"))


func test_an_id_is_forgotten_after_the_window() -> void:
	var seen: TwitchSeenMessages = _make()
	seen.remember("a", 0)

	seen.expire(WINDOW + 1)

	assert_false(seen.has("a"))
	assert_true(seen.remember("a", WINDOW + 1), "a forgotten id counts as new again")


func test_only_outdated_ids_are_forgotten() -> void:
	var seen: TwitchSeenMessages = _make()
	seen.remember("old", 0)
	seen.remember("new", 500)

	seen.expire(WINDOW + 1)

	assert_false(seen.has("old"))
	assert_true(seen.has("new"))


func test_the_oldest_ids_are_forgotten_beyond_the_maximum() -> void:
	var seen: TwitchSeenMessages = _make(3)

	for id: String in ["a", "b", "c", "d"]:
		seen.remember(id, 0)

	assert_eq(seen.size(), 3, "the maximum has to hold during a burst")
	assert_false(seen.has("a"), "the oldest one goes first")
	assert_true(seen.has("d"))


## The order list is compacted from time to time, which must not lose or keep
## the wrong ids.
func test_compacting_keeps_exactly_the_ids_within_the_window() -> void:
	# Wide enough that nothing expires while filling.
	var seen: TwitchSeenMessages = TwitchSeenMessages.new(10000)
	for index: int in 3000:
		seen.remember(str(index), index)
	seen.window_msec = WINDOW

	seen.expire(2500)

	assert_eq(seen.size(), 1500, "ids 0 to 1499 are older than the window")
	assert_false(seen.has("1499"))
	assert_true(seen.has("1500"))
	assert_true(seen.has("2999"))
	assert_lt(seen._order.size(), 3000, "the expired part of the order has to be dropped")


func test_to_dictionary_is_a_copy() -> void:
	var seen: TwitchSeenMessages = _make()
	seen.remember("a", 7)

	var copy: Dictionary[String, int] = seen.to_dictionary()
	copy.erase("a")

	assert_eq(copy, {} as Dictionary[String, int])
	assert_true(seen.has("a"), "changing the copy must not change what is remembered")
	assert_eq(seen.to_dictionary(), {"a": 7} as Dictionary[String, int])
