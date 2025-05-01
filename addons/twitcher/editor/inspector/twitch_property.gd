extends RefCounted

## Helper class for easier editing of Project Settings
class_name TwitchProperty

var key: String;
var default_value: Variant;

func _init(k: String, default_val: Variant = "") -> void:
	key = k;
	default_value = default_val;
	_add_property()


func _add_property():
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, default_value);
	ProjectSettings.set_initial_value(key, default_value);


func get_val() -> Variant:
	return ProjectSettings.get_setting_with_override(key);


func set_val(val) -> void:
	ProjectSettings.set(key, val);


func basic() -> TwitchProperty:
	ProjectSettings.set_as_basic(key, true);
	return self;


func as_str(description: String = "") -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, description);


func as_select(values: Array[String], optional: bool = true) -> TwitchProperty:
	var hint_string = ",".join(values);
	var enum_hint = PROPERTY_HINT_ENUM;
	if optional: enum_hint = PROPERTY_HINT_ENUM_SUGGESTION;
	return _add_type_def(TYPE_STRING, enum_hint, hint_string);


func as_bit_field(values: Array[String]) -> TwitchProperty:
	var hint_string = ",".join(values);
	return _add_type_def(TYPE_INT, PROPERTY_HINT_FLAGS, hint_string);


func as_password(description: String = "") -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_PASSWORD, description);


func as_bool(description: String = "") -> TwitchProperty:
	return _add_type_def(TYPE_BOOL, PROPERTY_HINT_PLACEHOLDER_TEXT, description)


func as_num() -> TwitchProperty:
	return _add_type_def(TYPE_INT, PROPERTY_HINT_NONE, "")


func as_global() -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_FILE, "");


func as_image() -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_FILE, "*.png,*.jpg,*.tres")


func as_dir() -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_DIR, "");


## Type should be the generic type of the array
func as_list(type: Variant = "") -> TwitchProperty:
	return _add_type_def(TYPE_ARRAY, PROPERTY_HINT_ARRAY_TYPE, type);


## The hint string can be a set of filters with wildcards like "*.png,*.jpg"
func as_global_save(file_types: String = "") -> TwitchProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_SAVE_FILE, file_types)


func _add_type_def(type: int, hint: int, hint_string: Variant) -> TwitchProperty:
	ProjectSettings.add_property_info({
	   "name": key,
	   "type": type,
	   "hint": hint,
	   "hint_string": hint_string
	})
	return self
