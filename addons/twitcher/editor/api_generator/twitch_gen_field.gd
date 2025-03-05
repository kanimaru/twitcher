@tool
extends TwitchGen

class_name TwitchGenField

var _name: String:
	set = _update_name
var _description: String
var _type: String
var _is_required: bool
var _is_sub_class: bool:
	get(): return _type.begins_with("#")
var _is_array: bool
var _is_typed_array: bool:
	get(): return _is_array && _type.begins_with("#")
	

## Couple of names from the Twitch API are messed up like keywords for godot or numbers
func _update_name(val: String) -> void:
	match val:
		"animated": _name = "animated_format"
		"static": _name = "static_format"
		"1": _name = "_1"
		"2": _name = "_2"
		"3": _name = "_3"
		"4": _name = "_4"
		"1.5": _name = "_1_5"
		"100x100": _name = "_100x100"
		"24x24": _name = "_24x24"
		"300x200": _name = "_300x200"
		_: _name = val
