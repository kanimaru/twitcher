@tool
extends TwitchGen

class_name TwitchGenComponent

var _classname: String
var _ref: String
var _description: String
var _fields: Array[TwitchGenField] = []
var _field_map: Dictionary[String, TwitchGenField] = {}
var _parent_component: TwitchGenComponent
var _sub_components: Dictionary[String, TwitchGenComponent] = {}
var _is_root: bool
var _is_response: bool
var _has_paging: bool
var _filename: String:
	get(): return _classname.to_snake_case() + ".gd"
	
	
func _init(classname: String, ref: String) -> void:
	_classname = _sanatize_classname(classname)
	_ref = ref
	
	
func add_field(field: TwitchGenField) -> void:
	_fields.append(field)
	_field_map[field._name] = field
	if field._name == "pagination":
		_has_paging = true
	
	
func get_field_by_name(field_name: String) -> TwitchGenField:
	return _field_map.get(field_name, null)
	
	
func get_root_classname() -> String:
	var parent: TwitchGenComponent = self
	while parent._parent_component != null:
		parent = parent._parent_component
	return parent._classname
	
	
func get_filename() -> String:
	return get_root_classname().to_snake_case() + ".gd"


func _sanatize_classname(val: String) -> String:
	match val:
		"Image": return "TwitchImage"
		"Panel": return "TwitchPanel"
		_: return val
		

func get_component(component_name: String) -> TwitchGenComponent:
	return _sub_components.get(component_name)


func add_component(sub_component: TwitchGenComponent) -> void:
	_sub_components[sub_component._classname] = sub_component
	sub_component._parent_component = self
