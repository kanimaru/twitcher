@icon("res://addons/twitcher/assets/api-icon.svg")
@tool
extends Twitcher

class_name TwitchAPIParser

const SWAGGER_API = "https://raw.githubusercontent.com/DmitryScaletta/twitch-api-swagger/refs/heads/main/openapi.json"

var definition: Dictionary = {}
var component_map: Dictionary[String, TwitchGenComponent] = {}
var components: Array[TwitchGenComponent] = []
var methods: Array[TwitchGenMethod] = []

var client: BufferedHTTPClient = BufferedHTTPClient.new()

signal component_added(component: TwitchGenComponent)
signal method_added(method: TwitchGenMethod)


class ComponentRepo extends RefCounted:
	var _component: TwitchGenComponent
	var _component_map: Dictionary[String, TwitchGenComponent]
	
	
	func get_comp(component_name: String) -> TwitchGenComponent:
		var component = _component.get_component(component_name)
		if component != null: return component
		return _component_map.get(component_name)
	
	
	func _init(component: TwitchGenComponent, component_map: Dictionary[String, TwitchGenComponent]) -> void:
		_component = component
		_component_map = component_map


func _ready() -> void:
	client.name = "APIGeneratorClient"
	

func parse_api() -> void:
	print("start generating API")
	if definition == {}:
		print("load Twitch definition")
		definition = await _load_swagger_definition()
		
	_parsing_components()
	_parsing_paths()
	
	
func _load_swagger_definition() -> Dictionary:
	add_child(client)
	client.max_error_count = 3
	var request = client.request(SWAGGER_API, HTTPClient.METHOD_GET, {}, "")
	var response_data = await client.wait_for_request(request)

	if response_data.error:
		printerr("Cant generate API")
		return {}
	var response_str = response_data.response_data.get_string_from_utf8()
	var response = JSON.parse_string(response_str)
	remove_child(client)
	return response


func _parsing_components() -> void:
	var schemas = definition["components"]["schemas"]
	for schema_name in schemas:
		var schema: Dictionary = schemas[schema_name]
		if schema["type"] != "object":
			printerr("Not an object")
			continue
			
		var ref = "#/components/schemas/" + schema_name
		var component = TwitchGenComponent.new(schema_name, ref)
		component._is_root = true
		component._is_response = true
		_parse_properties(component, schema)
		_add_component(ref, component)
		
		
func _parse_properties(component: TwitchGenComponent, schema: Dictionary) -> void:
	var properties = schema["properties"]
	for property_name: String in properties:
		var property: Dictionary = properties[property_name]
		var field: TwitchGenField = TwitchGenField.new()
		field._name = property_name
		field._description = property.get("description", "")
		field._type = _get_param_type(property)
		
		var classname: String = property_name.capitalize().replace(" ", "")
		
			
		if property.has("properties"):
			var sub_component = _add_sub_component(classname, field._description, component, property)
			field._type = sub_component._ref
		
		## Arrays that has custom types
		elif property.get("type", "") == "array":
			field._is_array = true
			field._is_sub_class = false
			var items = property.get("items", {})
			if items.has("$ref"):
				field._type = items.get("$ref")
			elif items.has("properties"):
				var sub_component = _add_sub_component(classname, field._description, component, items)				
				field._type = sub_component._ref

		component.add_field(field)
	
	var requires: Array = schema.get("required", [])
	for required_field: String in requires:
		var field: TwitchGenField = component.get_field_by_name(required_field)
		field._is_required = true


func _add_sub_component(classname: String, description: String, parent_component: TwitchGenComponent, properties: Dictionary) -> TwitchGenComponent:
	var ref: String = parent_component._ref + "/" + classname
	var sub_component = TwitchGenComponent.new(classname, ref)
	sub_component._description = description
	_parse_properties(sub_component, properties)
	parent_component.add_component(sub_component)
	_add_component(ref, sub_component)
	return sub_component


func _parsing_paths() -> void:
	var paths = definition.get("paths", {})
	for path in paths:
		var method_specs = paths[path]
		for http_verb: String in method_specs:
			var method_spec = method_specs[http_verb] as Dictionary
			var method = _parse_method(http_verb, method_spec)
			method._path = path
			if method._contains_optional:
				var component : TwitchGenComponent = method.get_optional_component()
				_add_component(component._ref, component)
			methods.append(method)
			method_added.emit(method)


func _parse_method(http_verb: String, method_spec: Dictionary) -> TwitchGenMethod:
	var method: TwitchGenMethod = TwitchGenMethod.new()
	method._http_verb = http_verb
	method._name = method_spec.get("operationId", "method_" + http_verb).replace("-", "_")
	method._summary = method_spec.get("summary", "No summary provided.")
	method._description = method_spec.get("description", "No description provided.")
	method._doc_url = method_spec.get("externalDocs", {}).get("url", "No link provided")
	_parse_parameters(method, method_spec)

	# Body Type
	if method_spec.has("requestBody"):
		method._body_type = "Dictionary"
		var ref = method_spec.get("requestBody").get("content", {}).get("application/json", {}).get("schema", {}).get("$ref", "")
		if ref != "":
			method._body_type = ref
	
	# Result Type
	method._result_type = "BufferedHTTPClient.ResponseData"
	var responses = method_spec.get("responses", {})
	if responses.has("200") || responses.has("202"):
		var content: Dictionary = {}
		if responses.has("200"):
			content = responses["200"].get("content", {})
		elif content == {}:
			content = responses["202"].get("content", {})

		# Assuming the successful response is a JSON object
		method._result_type = "Dictionary"

		# Special case for /schedule/icalendar
		if content.has("text/calendar"):
			method._result_type = "BufferedHTTPClient.ResponseData"


		# Try to resolve the component references
		var ref = content.get("application/json", {}).get("schema", {}).get("$ref", "")
		if ref != "":
			method._result_type = ref

	# Content Type
	if method_spec.has("requestBody"):
		var requestBody = method_spec.get("requestBody")
		var content = requestBody.get("content")
		method._content_type = content.keys()[0]
	elif http_verb == "POST":
		method._content_type = "application/x-www-form-urlencoded"
	return method


func _parse_parameters(method: TwitchGenMethod, method_spec: Dictionary) -> void:
	var parameter_specs = method_spec.get("parameters", [])
	for parameter_spec in parameter_specs:
		var parameter: TwitchGenParameter = TwitchGenParameter.new()
		var schema = parameter_spec["schema"]
		parameter._name = parameter_spec.get("name", "")
		parameter._description = parameter_spec.get("description", "")
		parameter._type = _get_param_type(schema)
		parameter._required = parameter_spec.get("required", false)
		parameter._is_time = schema.get("format", "") == "date-time"
		parameter._is_array = schema.get("type", "") == "array"
		method.add_parameter(parameter)
		

func _add_component(ref: String, component: TwitchGenComponent) -> void:
	components.append(component)
	component_map[ref] = component


func get_component_by_ref(ref: String) -> TwitchGenComponent:
	return component_map[ref]


func _get_param_type(schema: Dictionary) -> String:
	if schema.has("$ref"):
		return schema["$ref"]

	if not schema.has("type"):
		return "Variant" # Maybe ugly

	var type = schema["type"]
	var format = schema.get("format", "")
	match type:
		"object":
			if schema.has("additinalProperties"):
				return _get_param_type(schema["additinalProperties"])
			return "Dictionary"
		"string":
			# Why did I do this in the first place? 
			# Lets disable and see if problems appear
			#if format == "date-time":
			#	return "Variant"
			return "String"
		"integer":
			return "int"
		"number":
			return "float" if format == "float" else "int"
		"boolean":
			return "bool"
		"array":
			var ref: String = schema["items"].get("$ref", "")
			if schema["items"].get("type", "") == "string":
				return "String"
			elif ref != "":
				return ref
			else:
				return "Variant"
		_: return "Variant"
