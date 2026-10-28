extends TwitcherTest
## Unit tests for [UserConverter], the user field of the Twitcher inspectors.

const USER_CONVERTER: PackedScene = preload(
		"res://addons/twitcher/editor/inspector/user_converter.tscn")

var _default_user: TwitchUser
var _source: FakeDefaultUserSource
var _changes: Array[TwitchUser] = []
var _lookups: Array[TwitchGetUsers.Opt] = []


func before_each() -> void:
	super()
	_default_user = _make_user("100", "default_user")
	_source = FakeDefaultUserSource.new(_default_user, true)
	_changes = []
	_lookups = []


func test_auto_fill_puts_the_default_user_into_an_empty_field() -> void:
	var converter: UserConverter = _add_converter(true)
	await wait_process_frames(2)

	assert_eq(converter.user_id, "100")
	assert_eq(converter.user_login, "default_user")
	assert_eq(_changes, [_default_user] as Array[TwitchUser])


## channel.raid takes only one of from/to_broadcaster_user_id, filling the empty one on its own
## makes Twitch reject the subscription.
func test_disabled_auto_fill_leaves_an_empty_field_empty() -> void:
	var converter: UserConverter = _add_converter(false)
	await wait_process_frames(2)

	assert_eq(converter.user_id, "")
	assert_eq(converter.user_login, "")
	assert_eq(_changes.size(), 0)


func test_auto_fill_follows_the_default_user_source() -> void:
	_source.auto_fill_enabled = false
	var converter: UserConverter = _add_converter(true)
	await wait_process_frames(2)

	assert_eq(converter.user_id, "")
	assert_eq(_changes.size(), 0)


func test_auto_fill_keeps_a_field_that_already_holds_a_user() -> void:
	var stored_user: TwitchUser = _make_user("200", "stored_user")
	var converter: UserConverter = _add_converter(true)
	converter.update_user(stored_user)
	await wait_process_frames(2)

	assert_eq(converter.user_id, "200")
	assert_eq(_changes.size(), 0)


func test_use_default_user_fills_the_field_without_auto_fill() -> void:
	var converter: UserConverter = _add_converter(false)
	await wait_process_frames(2)

	converter.use_default_user()

	assert_eq(converter.user_id, "100")
	assert_same(converter.user, _default_user)
	assert_eq(_changes, [_default_user] as Array[TwitchUser])


func test_use_default_user_replaces_another_user() -> void:
	var converter: UserConverter = _add_converter(false)
	converter.update_user(_make_user("200", "stored_user"))

	converter.use_default_user()

	assert_eq(converter.user_id, "100")
	assert_eq(_changes, [_default_user] as Array[TwitchUser])


func test_use_default_user_without_a_default_user_changes_nothing() -> void:
	_source.user = null
	var converter: UserConverter = _add_converter(false)

	converter.use_default_user()

	assert_eq(converter.user_id, "")
	assert_null(converter.user)
	assert_eq(_changes.size(), 0)


func test_the_default_user_button_uses_the_default_user() -> void:
	var converter: UserConverter = _add_converter(false)

	_default_user_button(converter).pressed.emit()

	assert_eq(converter.user_id, "100")
	assert_eq(_changes, [_default_user] as Array[TwitchUser])


func test_the_default_user_button_is_shown_by_default() -> void:
	var converter: UserConverter = _add_converter(false)

	assert_true(_default_user_button(converter).visible)


func test_the_default_user_button_can_be_hidden_before_ready() -> void:
	var converter: UserConverter = USER_CONVERTER.instantiate()
	converter.show_default_user_button = false
	converter.default_user_source = _source
	add_child_autofree(converter)

	assert_false(_default_user_button(converter).visible)


func test_the_default_user_button_can_be_toggled_after_ready() -> void:
	var converter: UserConverter = _add_converter(false)

	converter.show_default_user_button = false
	assert_false(_default_user_button(converter).visible)

	converter.show_default_user_button = true
	assert_true(_default_user_button(converter).visible)


func test_the_default_user_button_is_a_small_icon() -> void:
	var button: Button = _default_user_button(_add_converter(false))

	assert_eq(button.text, "")
	assert_not_null(button.icon)


func test_the_default_user_button_names_the_default_user() -> void:
	var button: Button = _default_user_button(_add_converter(false))

	assert_false(button.disabled)
	assert_string_contains(button.tooltip_text, "default_user")


func test_the_default_user_button_is_disabled_without_a_default_user() -> void:
	_source.user = null
	var button: Button = _default_user_button(_add_converter(false))

	assert_true(button.disabled)
	assert_string_contains(button.tooltip_text, "Twitcher setup")


func test_the_default_user_button_is_disabled_while_the_field_holds_it() -> void:
	var converter: UserConverter = _add_converter(false)
	var button: Button = _default_user_button(converter)

	converter.use_default_user()
	assert_true(button.disabled)

	converter.update_user(_make_user("200", "stored_user"))
	assert_false(button.disabled)

	converter.update_user(null)
	assert_false(button.disabled)


## A condition stored without its user metadata is shown by id and reloaded. That used to swap in
## the default user instead of looking the stored id up.
func test_reload_looks_up_a_stored_id_instead_of_using_the_default_user() -> void:
	var stored_user: TwitchUser = _make_user("200", "stored_user")
	var converter: UserConverter = _add_converter(true)
	converter.user_lookup = func(opt: TwitchGetUsers.Opt) -> TwitchUser:
		_lookups.append(opt)
		return stored_user
	converter.user_id = "200"

	converter.reload()
	await wait_for_signal(converter.changed, 3)

	assert_eq(_lookups.size(), 1)
	assert_eq(_lookups[0].id, ["200"] as Array[String])
	assert_same(converter.user, stored_user)
	assert_eq(_changes, [stored_user] as Array[TwitchUser])


func test_reload_of_an_empty_field_reports_no_user() -> void:
	var converter: UserConverter = _add_converter(false)
	await wait_process_frames(2)

	converter.reload()
	await wait_for_signal(converter.changed, 3)

	assert_eq(_changes, [null] as Array[TwitchUser])
	assert_eq(_lookups.size(), 0)


func _add_converter(auto_fill: bool) -> UserConverter:
	var converter: UserConverter = USER_CONVERTER.instantiate()
	converter.auto_fill_default_user = auto_fill
	converter.default_user_source = _source
	converter.user_lookup = _fail_lookup
	converter.changed.connect(_on_changed)
	add_child_autofree(converter)
	return converter


func _default_user_button(converter: UserConverter) -> Button:
	return converter.get_node("%UseDefaultUser")


func _make_user(id: String, login: String) -> TwitchUser:
	var user: TwitchUser = TwitchUser.new()
	user.id = id
	user.login = login
	return user


func _fail_lookup(opt: TwitchGetUsers.Opt) -> TwitchUser:
	_lookups.append(opt)
	fail_test("no Twitch lookup expected")
	return null


func _on_changed(user: TwitchUser) -> void:
	_changes.append(user)


## Serves a fixed default user so the converter runs without the editor settings.
class FakeDefaultUserSource:
	extends TwitchDefaultUserSource

	var user: TwitchUser
	var auto_fill_enabled: bool


	func _init(default_user: TwitchUser, auto_fill: bool) -> void:
		user = default_user
		auto_fill_enabled = auto_fill


	func get_user() -> TwitchUser:
		return user


	func is_auto_fill_enabled() -> bool:
		return auto_fill_enabled
