extends TwitcherTest
## Unit tests for [TwitchLogContextRow].

var _row: TwitchLogContextRow
var _shown: Array[Array] = []
var _modes: Array[Array] = []


func before_each() -> void:
	super()
	_shown = []
	_modes = []
	_row = TwitchLogContextRow.new("TwitchAuth")
	_row.shown_changed.connect(_on_shown_changed)
	_row.mode_changed.connect(_on_mode_changed)
	add_child_autofree(_row)


func test_starts_shown_and_off() -> void:
	assert_eq(_row.context, "TwitchAuth")
	assert_true(_row.is_shown())
	assert_eq(_row.get_mode(), "off")


func test_the_user_toggling_emits_shown_changed() -> void:
	_row.toggle_shown(false)

	assert_false(_row.is_shown())
	assert_eq(_shown, [["TwitchAuth", false]] as Array[Array])


func test_the_user_picking_a_mode_emits_mode_changed() -> void:
	_row.pick_mode("debug")

	assert_eq(_row.get_mode(), "debug")
	assert_eq(_modes, [["TwitchAuth", "debug"]] as Array[Array])


func test_setters_update_silently() -> void:
	_row.set_shown(false)
	_row.set_mode("info")

	assert_false(_row.is_shown())
	assert_eq(_row.get_mode(), "info")
	assert_eq(_shown.size(), 0)
	assert_eq(_modes.size(), 0)


func test_unknown_modes_are_ignored() -> void:
	_row.set_mode("info")
	_row.set_mode("verbose")
	_row.pick_mode("verbose")

	assert_eq(_row.get_mode(), "info")
	assert_eq(_modes.size(), 0)


func _on_shown_changed(context: String, is_shown: bool) -> void:
	_shown.append([context, is_shown])


func _on_mode_changed(context: String, mode: String) -> void:
	_modes.append([context, mode])
