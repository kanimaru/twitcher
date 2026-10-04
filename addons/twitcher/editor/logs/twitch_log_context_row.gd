@tool
class_name TwitchLogContextRow
extends HBoxContainer
## One context in the [TwitchLogDock]: a check box that shows or hides its records
## in the panel and a selector for its mode (off, info, debug).
##
## The setters update the controls without emitting a signal, so a row can follow
## changes made elsewhere. Only the user's own input emits.

## The user toggled the check box.
signal shown_changed(context: String, is_shown: bool)
## The user picked a mode.
signal mode_changed(context: String, mode: String)

var context: String

var _check: CheckBox
var _mode_select: OptionButton


func _init(context_name: String) -> void:
	context = context_name
	name = context_name

	_check = CheckBox.new()
	_check.text = context_name
	_check.tooltip_text = "Show the records of %s in this panel" % context_name
	_check.button_pressed = true
	_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_check.clip_text = true
	_check.toggled.connect(_on_check_toggled)
	add_child(_check)

	_mode_select = OptionButton.new()
	_mode_select.tooltip_text = "What %s logs, stored in the project settings" % context_name
	for mode: String in TwitchLogContexts.MODES:
		_mode_select.add_item(mode)
	_mode_select.item_selected.connect(_on_mode_selected)
	add_child(_mode_select)


func is_shown() -> bool:
	return _check.button_pressed


func get_mode() -> String:
	return TwitchLogContexts.MODES[_mode_select.selected]


## Updates the check box without emitting [signal shown_changed].
func set_shown(is_shown_now: bool) -> void:
	_check.set_pressed_no_signal(is_shown_now)


## Updates the selector without emitting [signal mode_changed]. Unknown modes are
## ignored.
func set_mode(mode: String) -> void:
	var index: int = TwitchLogContexts.MODES.find(mode)
	if index >= 0:
		_mode_select.select(index)


## Simulates the user picking [param mode], e.g. for tests.
func pick_mode(mode: String) -> void:
	var index: int = TwitchLogContexts.MODES.find(mode)
	if index < 0:
		return
	_mode_select.select(index)
	_on_mode_selected(index)


## Simulates the user toggling the check box, e.g. for tests.
func toggle_shown(is_shown_now: bool) -> void:
	_check.button_pressed = is_shown_now


func _on_check_toggled(is_pressed: bool) -> void:
	shown_changed.emit(context, is_pressed)


func _on_mode_selected(index: int) -> void:
	mode_changed.emit(context, TwitchLogContexts.MODES[index])
