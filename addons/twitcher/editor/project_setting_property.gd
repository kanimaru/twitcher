@tool
extends RefCounted

class_name ProjectSettingProperty

var key: String
var default_value: Variant


func _init(k: String, default_val: Variant = "") -> void:
	key = k
	default_value = default_val
	_add_property()


func _add_property():
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, default_value)
	ProjectSettings.set_initial_value(key, default_value)


func get_val() -> Variant:
	return ProjectSettings.get_setting_with_override(key)


func set_val(val) -> void:
	ProjectSettings.set(key, val)


func basic() -> ProjectSettingProperty:
	ProjectSettings.set_as_basic(key, true)
	return self


func as_str(description: String = "") -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, description)


func as_select(values: Array[String], optional: bool = true) -> ProjectSettingProperty:
	var hint_string = ",".join(values)
	var enum_hint = PROPERTY_HINT_ENUM
	if optional: enum_hint = PROPERTY_HINT_ENUM_SUGGESTION
	return _add_type_def(TYPE_STRING, enum_hint, hint_string)


# Won't work in godot 4.4 the resource is not loaded when you select the project and it will just drop it out of the list.
#func as_resoruce(resource_name: StringName) -> ProjectSettingProperty:
#	return _add_type_def(TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE, resource_name)
	

func as_bit_field(values: Array[String]) -> ProjectSettingProperty:
	var hint_string = ",".join(values)
	return _add_type_def(TYPE_INT, PROPERTY_HINT_FLAGS, hint_string)


func as_password(description: String = "") -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_PASSWORD, description)


func as_bool(description: String = "") -> ProjectSettingProperty:
	return _add_type_def(TYPE_BOOL, PROPERTY_HINT_PLACEHOLDER_TEXT, description)


func as_num() -> ProjectSettingProperty:
	return _add_type_def(TYPE_INT, PROPERTY_HINT_NONE, "")


func as_global() -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_FILE, "")


## file_type is comma separated values "*.png,*.jpg,*.tres"
func as_file(file_type: String) -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_FILE, file_type)


func as_dir() -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_DIR, "")


## Type should be the generic type of the array
func as_list(type: Variant = "") -> ProjectSettingProperty:
	return _add_type_def(TYPE_ARRAY, PROPERTY_HINT_ARRAY_TYPE, type)


## The hint string can be a set of filters with wildcards like "*.png,*.jpg"
func as_global_save(file_types: String = "") -> ProjectSettingProperty:
	return _add_type_def(TYPE_STRING, PROPERTY_HINT_GLOBAL_SAVE_FILE, file_types)


func _add_type_def(type: int, hint: int, hint_string: Variant) -> ProjectSettingProperty:
	ProjectSettings.add_property_info({
	   "name": key,
	   "type": type,
	   "hint": hint,
	   "hint_string": hint_string
	})
	return self
