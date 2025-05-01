@tool
extends TwitchGen

class_name TwitchGenMethod
var _http_verb: String
var _name: String
var _summary: String
var _description: String
var _path: String
var _doc_url: String
var _parameters: Array[TwitchGenParameter] = []
var _parameter_map: Dictionary[String, TwitchGenParameter] = {}
var _required_parameters: Array[TwitchGenParameter]: 
	get(): return _parameters.filter(func(p): return p._required)
var _optional_parameters: Array[TwitchGenParameter]: 
	get(): return _parameters.filter(func(p): return not p._required)
var _body_type: String
var _result_type: String
var _content_type: String
var _has_paging: bool
var _contains_optional: bool
var _contains_body: bool:
	get(): return _body_type != null and _body_type != ""

	
func add_parameter(parameter: TwitchGenParameter) -> void:
	_parameters.append(parameter)
	_contains_optional = _contains_optional || not parameter._required
	_parameter_map[parameter._name] = parameter
	if parameter._name == "after":
		_has_paging = true


func get_parameter_by_name(name: String) -> TwitchGenParameter:
	return _parameter_map.get(name)


func get_optional_classname() -> String:
	return _name.capitalize().replace(" ", "") + "Opt"


func get_optional_type() -> String:
	return "#/components/schemas/" + get_optional_classname()


func get_optional_component() -> TwitchGenComponent:
	var component = TwitchGenComponent.new(get_optional_classname(), get_optional_type())
	component._description = "All optional parameters for TwitchAPI.%s" % _name
	component._is_root = true
	for parameter: TwitchGenParameter in _optional_parameters:
		var field = TwitchGenField.new()
		field._name = parameter._name
		field._type = parameter._type
		field._description = parameter._description
		field._is_required = false
		field._is_array = parameter._is_array
		component.add_field(field)
	
	return component
