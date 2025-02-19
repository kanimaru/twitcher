@tool
extends Node

## Please do not touch! Insane code ahead! Last Warning!

class_name TwitchAPIGenerator

const SWAGGER_API = "https://raw.githubusercontent.com/DmitryScaletta/twitch-api-swagger/refs/heads/main/openapi.json"
const api_output_path = "res://addons/twitcher/generated/twitch_api.gd"

var client: BufferedHTTPClient = BufferedHTTPClient.new()
var definition: Dictionary = {}

#region Definition
class Method extends RefCounted:
	var _http_verb: String
	var _name: String
	var _summary: String
	var _description: String
	var _path: String
	var _doc_url: String
	var _parameters: Array[Parameter] = []
	var _required_parameters: Array[Parameter]: 
		get(): return _parameters.filter(func(p): return p._required)
	var _optional_parameters: Array[Parameter]: 
		get(): return _parameters.filter(func(p): return not p._required)
	var _body_type: String
	var _result_type: String
	var _content_type: String
	
	var _contains_optional: bool
	var _contains_body: bool:
		get(): return _body_type != null and _body_type != ""
		
		
	func add_parameter(parameter: Parameter) -> void:
		_parameters.append(parameter)
		_contains_optional = _contains_optional || not parameter._required


	func get_optional_type() -> String:
		if _result_type == "BufferedHTTPClient.ResponseData":
			return _name.capitalize().replace(" ", "") + "Opt"
		return _result_type.trim_suffix("Response") + "Opt"


	func get_optional_class() -> String:
		var body = "class %s extends TrackedData:" % get_optional_type()
		for parameter: Parameter in _optional_parameters:
			body += """
	## {documentation}
	var {property}""".format({
		'documentation': parameter._documention.replace("\n", "\n\t## "),
		'property': parameter.get_code(true)
	})
		return body + "\n"


	func get_parameter_doc() -> String:
		if _parameters.is_empty():
			return "## [no query parameters to describe]"
		var doc : String = ""
		for parameter: Parameter in _required_parameters:
			doc += "## {name} - {documentation} \n".format({
				'name': parameter._name,
				'documentation': parameter._documention.replace("\n", "\n##   ")
			})
		return doc.rstrip("\n")

	func get_parameter_code() -> String:
		var parameter_code : String = ""
		if _contains_body: parameter_code += "body: %s, " % _body_type
		if _contains_optional: parameter_code += "opt: %s, " % get_optional_type()
					
		_parameters.sort_custom(Parameter.sort)
		for parameter: Parameter in _required_parameters:
			parameter_code += parameter.get_code() + ", "
		return parameter_code.rstrip(", ")
		
		
	func get_path_code() -> String:
		var body_code : String = "var path = \"%s?\"\n" % _path
		if _contains_optional:
			body_code += "\tvar optionals: Dictionary[StringName, Variant] = {}\n"
			body_code += "\tif opt != null: optionals = opt.updated_values()\n"
			
		for parameter: Parameter in _parameters:
			if parameter._required:
				body_code += "\t" + parameter.get_body() + "\n"
			else:
				body_code += "\tif optionals.has(\"%s\"):\n" % parameter._name
				body_code += "\t\t%s\n" % parameter.get_body("optionals.").replace("\n", "\n\t")
		return body_code


	func get_response_code() -> String:
		if _result_type != "BufferedHTTPClient.ResponseData":
			return """
	var result: Variant = JSON.parse_string(response.response_data.get_string_from_utf8())
	var parsed_result: {result_type} = {result_type}.from_json(result)
	return parsed_result""".format({
				'result_type': _result_type
			})
		else:
			return "return response"


	func get_code() -> String:
		var code : String = "\n\n"
		if _contains_optional:
			code += get_optional_class() + "\n"
		
		code += """
## {summary}
## 
{parameter_doc}
##
## {doc_url}
func {name}({parameters}) -> {result_type}:
	{path_code}
	var response: BufferedHTTPClient.ResponseData = await request(path, HTTPClient.METHOD_{method}, {body_variable}, "{content_type}")
	{response_code}
""".format({
			'summary': _summary,
			'parameter_doc': get_parameter_doc(),
			'doc_url': _doc_url,
			'name': _name,
			'parameters': get_parameter_code(),
			'result_type': _result_type,
			'path_code': get_path_code(),
			'content_type': _content_type,
			'method': _http_verb.to_upper(),
			'body_variable': "body" if _contains_body else "\"\"",
			'response_code': get_response_code(),
		})
		return code


class Parameter extends RefCounted:
	var _name: String
	var _required: bool
	var _type: String
	var _is_time: bool
	var _is_array: bool
	var _documention: String
	
	func get_code(plain: bool = false) -> String:
		if _name == "broadcaster_id" && not plain:
			var default_value = "default_broadcaster_login" if _type == "String" else "[default_broadcaster_login]"
			return "%s: %s = %s" % [_name, _type, default_value]
		return "%s: %s" % [_name, _type]

		
	func get_body(prefix: String = "") -> String:
		var body: String
		if _is_time:
			body = "path += \"{key}=\" + get_rfc_3339_date_format({value}) + \"&\"" \
				.format({ 
					'value': prefix + _name,
					'key': _name 
				})
			
		elif _is_array:
			body = """
	for param in {value}:
		path += "{key}=" + str(param) + "&" """ \
					.format({ 
						'value': prefix + _name,
						'key': _name 
					}) \
					.trim_prefix("\n\t")
		else:
			body = "path += \"{key}=\" + str({value}) + \"&\"" \
				.format({ 
					'value': prefix + _name,
					'key': _name 
				})
					
		return body
	
	static func sort(p1: Parameter, p2: Parameter) -> bool:
		if p1._name == "broadcaster_id":
			return false
		if p2._name == "broadcaster_id":
			return true
		if p1._required && not p2._required:
			return true
		if not p1._required && p2._required:
			return false
		return p1._name < p2._name
		
	
#endregion

func _ready() -> void:
	client.name = "APIGeneratorClient"


func generate_api() -> void:
	print("start generating API")
	if definition == {}:
		print("load Twitch definition")
		definition = await _load_swagger_definition()
	_generate_api()
	#_generate_repositories()
	#_generate_components()
	print("API regenerated you can find it under: res://addons/twitcher/generated/")

#region Repository

func _load_swagger_definition() -> Dictionary:
	add_child(client)
	client.max_error_count = 3
	var request = client.request(SWAGGER_API, HTTPClient.METHOD_GET, {}, "")
	var response_data = await client.wait_for_request(request)

	if response_data.error:
		printerr("Cant generate API")
	var response_str = response_data.response_data.get_string_from_utf8()
	var response = JSON.parse_string(response_str)
	remove_child(client)
	return response


func _generate_api() -> void:
	var paths = definition.get("paths", {})
	var methods: Array[Method] = []
	for path in paths:
		var method_specs = paths[path]
		for http_verb: String in method_specs:
			var method_spec = method_specs[http_verb] as Dictionary
			var method = _parse_method(http_verb, method_spec)
			method._path = path
			methods.append(method)
	
	generate_methods(methods)
	

func _parse_method(http_verb: String, method_spec: Dictionary) -> Method:
	var method: Method = Method.new()
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
			method._body_type = _resolve_ref(ref)
	
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
			method._result_type = _resolve_ref(ref)

	# Content Type
	if method_spec.has("requestBody"):
		var requestBody = method_spec.get("requestBody")
		var content = requestBody.get("content")
		method._content_type = content.keys()[0]
	elif http_verb == "POST":
		method._content_type = "application/x-www-form-urlencoded"

	return method

	
func generate_methods(methods: Array[Method]) -> void:
	var result : String = """@tool
extends "res://addons/twitcher/editor/api_generator/twitch_base_api.gd"

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## Interaction with the Twitch REST API.
class_name TwitchAPI

## Broadcaster ID that will be used when no Broadcaster ID was given
@export var default_broadcaster_login: String:
	set(username):
		default_broadcaster_login = username
		_update_default_broadcaster_login(username)
		update_configuration_warnings()
	get():
		if default_broadcaster_login == null || default_broadcaster_login == "":
			return ""
		return default_broadcaster_login

var broadcaster_user: TwitchUser:
	set(val):
		broadcaster_user = val
		notify_property_list_changed()

func _ready() -> void:
	client = BufferedHTTPClient.new()
	client.name = "ApiClient"
	add_child(client)
	if default_broadcaster_login == "" && token.is_token_valid():
		var opt = TwitchGetUsersOpt.new()
		var current_user : TwitchGetUsersResponse = await get_users(opt)
		var user: TwitchUser = current_user.data[0]
		default_broadcaster_login = user.id


func _update_default_broadcaster_login(username: String) -> void:
	if not is_node_ready(): await ready
	var opt = TwitchGetUsersOpt.new()
	opt.login = [username] as Array[String]
	var user_data : TwitchGetUsersResponse = await get_users(opt)
	if user_data.data.is_empty():
		printerr("Username was not found: %s" % username)
		return
	broadcaster_user = user_data.data[0]


func _get_configuration_warnings() -> PackedStringArray:
	if default_broadcaster_login == null || default_broadcaster_login == "":
		return ["Please set default broadcaster that is used when no broadcaster was explicitly given"]
	return []
	
	"""
	for method: Method in methods:
		result += method.get_code()
	result += """
## Converts unix timestamp to RFC 3339 (example: 2021-10-27T00:00:00Z) when passed a string uses as is
static func get_rfc_3339_date_format(time: Variant) -> String:
	if typeof(time) == TYPE_INT:
		var date_time = Time.get_datetime_dict_from_unix_time(time)
		return "%s-%02d-%02dT%02d:%02d:%02dZ" % [date_time['year'], date_time['month'], date_time['day'], date_time['hour'], date_time['minute'], date_time['second']]
	return str(time)
	"""
	write_output_file("res://addons/twitcher/generated/twitch_api.gd", result)
		

func _parse_parameters(method: Method, method_spec: Dictionary) -> void:
	var parameter_specs = method_spec.get("parameters", [])
	for parameter_spec in parameter_specs:
		var parameter: Parameter = Parameter.new()
		var schema = parameter_spec["schema"]
		parameter._name = parameter_spec.get("name", "")
		parameter._documention = parameter_spec.get("description", "")
		parameter._type = _get_param_type(schema)
		parameter._required = parameter_spec.get("required", false)
		parameter._is_time = schema.get("format", "") == "date-time"
		parameter._is_array = schema.get("type", "") == "array"
		method.add_parameter(parameter)

#endregion

# Writes the processed content to the output file.
func write_output_file(file_output: String, content: String) -> void:
	var file = FileAccess.open(file_output, FileAccess.WRITE);
	if file == null:
		var error_message = error_string(FileAccess.get_open_error());
		push_error("Failed to open output file: %s\n%s" % [file_output, error_message])
		return
	file.store_string(content)
	file.flush()
	file.close()


func _resolve_ref(ref: String) -> String:
	return "Twitch" + ref.substr(ref.rfind("/") + 1)


func _get_param_type(schema: Dictionary) -> String:
	if schema.has("$ref"):
		return _resolve_ref(schema["$ref"])

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
			if format == "date-time":
				return "Variant"
			return "String"
		"integer":
			return "int"
		"boolean":
			return "bool"
		"array":
			var ref: String = schema["items"].get("$ref", "")
			if schema["items"].get("type", "") == "string":
				return "Array[String]"
			elif ref != "":
				var ref_name = _resolve_ref(ref)
				return "Array[%s]" % ref_name
			else:
				return "Array"
		_: return "Variant"


func _sanatize_classname(cls_name: String) -> String:
	match cls_name:
		"Image": return "TwitchImage"
		"Panel": return "TwitchPanel"
		_: return cls_name


## Couple of names from the Twitch API are messed up like keywords for godot or numbers
func _to_field_name(property_name: String) -> String:
	match property_name:
		"animated": return "animated_format"
		"static": return "static_format"
		"1": return "_1"
		"2": return "_2"
		"3": return "_3"
		"4": return "_4"
		"1.5": return "_1_5"
		"100x100": return "_100x100"
		"24x24": return "_24x24"
		"300x200": return "_300x200"
		_: return property_name

#region Generate Components


func _generate_components():
	var template = SimpleTemplate.new()
	var schemas = definition["components"]["schemas"]
	for schema_name in schemas:
		var classes = []
		var properties: Array[Dictionary] = []
		_calculate_template(schema_name, schemas[schema_name], classes, properties)
		var data: Dictionary = {
			"class_name": "Twitch" + schema_name,
			"properties": properties,
			"classes": classes
		}
		var file_name : String = "Twitch" + schema_name + ".gd"
		file_name = file_name.to_snake_case()
		template.process_template("res://addons/twitcher/editor/api_generator/template_component.txt",
				data, "res://addons/twitcher/generated/" + file_name)


func _calculate_template(schema_name: String, schema: Dictionary, result_classes: Array, result_properties: Array[Dictionary]):
	if schema["type"] != "object":
		printerr("Not an object")
	var properties = schema["properties"]
	_parse_properties(properties, result_classes, result_properties)


func _parse_properties(properties: Dictionary, result_classes: Array, result_properties: Array[Dictionary]):
	for property_name in properties:
		var property = properties[property_name]
		var type = _get_param_type(property)
		var is_sub_class = property.has("$ref")
		var array_type = ""
		var is_typed_array = false

		if property.has("properties"):
			var class_description = property['description'].replace("\n", " ")
			var sub_class = _get_sub_classes(property_name, property['properties'], result_classes, class_description)
			result_classes.append(sub_class["code"])
			type = sub_class["name"]
			is_sub_class = true

		## Arrays that has custom types
		var is_array = false
		if property.get("type", "") == "array":
			is_sub_class = false
			var items = property.get("items", {})
			if items.has("$ref"):
				is_typed_array = true
				array_type = _resolve_ref(property.get("items", {}).get("$ref"))
			elif items.has("properties"):
				var array_properties = items.get("properties")
				var sub_class = _get_sub_classes(property_name, array_properties, result_classes)
				result_classes.append(sub_class["code"])
				array_type = sub_class["name"]
				type = "Array[" + sub_class["name"] + "]"
				is_typed_array = true
			else:
				is_array = true

		result_properties.append({
			"field_name": _to_field_name(property_name),
			"property_name": property_name,
			"type": type,
			"array_type": array_type,
			"is_property_sub_class": is_sub_class,
			"is_property_array": is_array,
			"is_property_typed_array": is_typed_array,
			"is_property_basic": (!is_typed_array && !is_array && !is_sub_class),
			"description": property.get("description", "No description available").replace("\n", " "),
		})


func _get_sub_classes(parent_property_name:String, properties: Dictionary, result_classes: Array, class_description: String = "") -> Dictionary:
	var template = SimpleTemplate.new()
	var template_component_class = template.read_template_file(
			"res://addons/twitcher/editor/api_generator/template_component_class.txt")
	var result_properties: Array[Dictionary] = []

	_parse_properties(properties, result_classes, result_properties)

	var cls_name = parent_property_name.capitalize().replace(" ", "")
	cls_name = _sanatize_classname(cls_name)

	var data = {
		"class_name": cls_name,
		"class_description": class_description,
		"properties": result_properties
	}
	return {
		"name": cls_name,
		"code": template.parse_template(template_component_class, data)
	}

#endregion
