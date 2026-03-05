@tool
extends TwitchGen

class_name TwitchGenComponent

var _classname: String:
	set(val): _classname = _sanatize_classname(val)
	get(): 
		#if _parent_component:
			#return _parent_component._base_classname + "_" + _classname
		#else:
		return _classname
var _fqdn: Callable # Function to create the final full quallified domain name returns string
var _ref: String
var _description: String
var _fields: Array[TwitchGenField] = []
var _field_map: Dictionary[String, TwitchGenField] = {}
var _parent_component: TwitchGenComponent
var _root_component: TwitchGenComponent
	#get(): 
		#var parent = self
		#while parent:
			#parent = _parent_component
		#return parent
var _sub_components: Dictionary[String, TwitchGenComponent] = {}
## All subcomponents from the childs too
var _recursive_sub_components: Dictionary[String, TwitchGenComponent] = {}
var _is_root: bool
var _is_response: bool:
	get(): return _classname.contains("Response")
	
var _has_paging: bool
var _filename: String:
	get(): return _classname.to_snake_case() + ".gd"
	
	
func _init() -> void:
	_root_component = self
	
	
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


func get_component_recursive(component_name: String) -> TwitchGenComponent:
	return _root_component._recursive_sub_components.get(component_name)


func add_component(sub_component: TwitchGenComponent) -> void:
	_sub_components[sub_component._classname] = sub_component
	sub_component._parent_component = self
	
	# Update the parents too
	var parent: TwitchGenComponent = self
	var latest_parent: TwitchGenComponent = self
	while parent:
		parent._recursive_sub_components[sub_component._classname] = sub_component
		parent = parent._parent_component
		if parent: latest_parent = parent
	sub_component._root_component = latest_parent
