## Unit tests for [OAuthScopes].
##
## A [Resource] with no dependencies — no tree, no network, no disk — so every
## test here is a plain [code].new()[/code].
##
## The scope set decides what the OAuth authorization URL asks Twitch for. If it
## is wrong the user is prompted for the wrong permissions, and the failure only
## surfaces later as a 401 from an unrelated endpoint.
extends TwitcherTest

var _scopes: OAuthScopes


func before_each() -> void:
	super()
	_scopes = OAuthScopes.new()


#region ssv_scopes

func test_ssv_scopes_is_empty_for_no_scopes() -> void:
	assert_eq(_scopes.ssv_scopes(), "")


func test_ssv_scopes_joins_with_single_space() -> void:
	_scopes.used_scopes = [&"chat:read", &"chat:edit", &"bits:read"]
	assert_eq(_scopes.ssv_scopes(), "chat:read chat:edit bits:read")


func test_ssv_scopes_does_not_pad_a_single_scope() -> void:
	_scopes.used_scopes = [&"chat:read"]
	assert_eq(_scopes.ssv_scopes(), "chat:read")

#endregion


#region add_scopes

func test_add_scopes_appends_to_empty() -> void:
	_scopes.add_scopes([&"chat:read", &"bits:read"])
	assert_eq(_scopes.used_scopes, [&"chat:read", &"bits:read"] as Array[StringName])


func test_add_scopes_preserves_insertion_order() -> void:
	_scopes.add_scopes([&"c", &"a", &"b"])
	assert_eq(_scopes.used_scopes, [&"c", &"a", &"b"] as Array[StringName])


func test_add_scopes_is_idempotent() -> void:
	_scopes.add_scopes([&"chat:read"])
	_scopes.add_scopes([&"chat:read"])
	assert_eq(_scopes.used_scopes.size(), 1, "adding the same scope twice must not duplicate it")


func test_add_scopes_deduplicates_against_existing() -> void:
	_scopes.used_scopes = [&"chat:read"]
	_scopes.add_scopes([&"chat:read", &"bits:read"])
	assert_eq(_scopes.used_scopes, [&"chat:read", &"bits:read"] as Array[StringName])


func test_add_scopes_with_empty_array_changes_nothing() -> void:
	_scopes.used_scopes = [&"chat:read"]
	_scopes.add_scopes([] as Array[StringName])
	assert_eq(_scopes.used_scopes, [&"chat:read"] as Array[StringName])

#endregion


#region remove_scopes

## Regression test for an inverted filter predicate.
##
## [code]remove_scopes()[/code] filtered with [code]scopes.find(s) != -1[/code],
## which [i]keeps[/i] exactly the scopes it was asked to remove and discards
## everything else — the precise inverse of its contract.
func test_remove_scopes_removes_the_named_scope() -> void:
	_scopes.used_scopes = [&"chat:read", &"chat:edit"]
	_scopes.remove_scopes([&"chat:read"])
	assert_eq(
		_scopes.used_scopes,
		[&"chat:edit"] as Array[StringName],
		"remove_scopes must drop the named scope and keep the rest"
	)


func test_remove_scopes_removes_several_at_once() -> void:
	_scopes.used_scopes = [&"a", &"b", &"c", &"d"]
	_scopes.remove_scopes([&"b", &"d"])
	assert_eq(_scopes.used_scopes, [&"a", &"c"] as Array[StringName])


func test_remove_scopes_ignores_scopes_that_are_not_present() -> void:
	_scopes.used_scopes = [&"chat:read"]
	_scopes.remove_scopes([&"bits:read"])
	assert_eq(_scopes.used_scopes, [&"chat:read"] as Array[StringName])


func test_remove_scopes_with_empty_array_changes_nothing() -> void:
	_scopes.used_scopes = [&"chat:read", &"chat:edit"]
	_scopes.remove_scopes([] as Array[StringName])
	assert_eq(
		_scopes.used_scopes,
		[&"chat:read", &"chat:edit"] as Array[StringName],
		"removing nothing must not clear the set"
	)


func test_remove_scopes_can_empty_the_set() -> void:
	_scopes.used_scopes = [&"chat:read"]
	_scopes.remove_scopes([&"chat:read"])
	assert_eq(_scopes.used_scopes, [] as Array[StringName])


func test_remove_scopes_preserves_order_of_survivors() -> void:
	_scopes.used_scopes = [&"a", &"b", &"c", &"d", &"e"]
	_scopes.remove_scopes([&"c"])
	assert_eq(_scopes.used_scopes, [&"a", &"b", &"d", &"e"] as Array[StringName])

#endregion


#region round trip

func test_add_then_remove_returns_to_start() -> void:
	_scopes.used_scopes = [&"chat:read"]
	_scopes.add_scopes([&"bits:read"])
	_scopes.remove_scopes([&"bits:read"])
	assert_eq(_scopes.used_scopes, [&"chat:read"] as Array[StringName])

#endregion


#region signals

func test_setting_used_scopes_emits_scopes_changed() -> void:
	watch_signals(_scopes)
	_scopes.used_scopes = [&"chat:read"]
	assert_signal_emitted(_scopes, "scopes_changed")


func test_add_scopes_emits_scopes_changed() -> void:
	watch_signals(_scopes)
	_scopes.add_scopes([&"chat:read"])
	assert_signal_emitted(_scopes, "scopes_changed")


func test_remove_scopes_emits_scopes_changed() -> void:
	_scopes.used_scopes = [&"chat:read"]
	watch_signals(_scopes)
	_scopes.remove_scopes([&"chat:read"])
	assert_signal_emitted(_scopes, "scopes_changed")


## [code]remove_scopes()[/code] assigns to [code]used_scopes[/code] — firing the
## property setter's emit — and then emits again explicitly, so listeners see the
## change twice.
##
## Harmless today (every listener just rereads the scope set), but it means a
## listener that counts changes or triggers a network call per change will do
## double work. Pinned so the behaviour is a decision rather than an accident.
func test_remove_scopes_emits_twice_known_behaviour() -> void:
	_scopes.used_scopes = [&"chat:read"]
	watch_signals(_scopes)
	_scopes.remove_scopes([&"chat:read"])
	assert_signal_emit_count(
		_scopes, "scopes_changed", 2,
		"setter emit + explicit emit; see doc comment"
	)

#endregion
