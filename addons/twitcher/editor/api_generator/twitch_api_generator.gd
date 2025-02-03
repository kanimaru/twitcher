@tool
extends Node

## Please do not touch! Insane code ahead! Last Warning!

class_name TwitchAPIGenerator

const SWAGGER_API = "https://raw.githubusercontent.com"
const api_output_path = "res://addons/twitcher/generated/twitch_api.gd"

var client: BufferedHTTPClient
var definition: Dictionary = {}

func _ready() -> void:
	client = BufferedHTTPClient.new()
	client.name = "APIGeneratorClient"
	add_child(client)

func generate_api() -> void:
	print("start generating API")
	if definition == {}:
		print("load Twitch definition")
		definition = await _load_swagger_definition()
	_generate_repositories()
	_generate_components()
	print("API regenerated you can find it under: res://addons/twitcher/generated/")

#region Repository


func _load_swagger_definition() -> Dictionary:
	EditorInterface.get_base_control().add_child(client)
	client.max_error_count = 3
	var request = client.request("/DmitryScaletta/twitch-api-swagger/refs/heads/main/openapi.json", HTTPClient.METHOD_GET, {}, "")
	var response_data = await client.wait_for_request(request)

	if response_data.error:
		printerr("Cant generate API")
	var response_str = response_data.response_data.get_string_from_utf8()
	var response = JSON.parse_string(response_str)
	EditorInterface.get_base_control().remove_child(client)
	return response


func _generate_repositories():
	var template = SimpleTemplate.new()
	var template_method = template.read_template_file("res://addons/twitcher/editor/api_generator/template_method.txt")
	var template_parameter_optional = template.read_template_file("res://addons/twitcher/editor/api_generator/template_method_parameters_optional.txt")
	var template_body_optional = template.read_template_file("res://addons/twitcher/editor/api_generator/template_method_body_optional.txt")
	var gdscript_code := ""
	var paths = definition.get("paths", {})
	var data = []
	for path in paths:
		var methods = paths[path]
		for http_method: String in methods:
			var method_spec = methods[http_method] as Dictionary
			var method_name = method_spec.get("operationId", "method_" + http_method).replace("-", "_")
			var summary = method_spec.get("summary", "No summary provided.")
			var description = method_spec.get("description", "No description provided.")
			var url = method_spec.get("externalDocs", {}).get("url", "No link provided")
			var parameters = _parse_parameters(method_spec)
			var has_body = parameters["has_body"]
			var header_code = "{}"
			var responses = method_spec.get("responses", {})
			var result_type = "BufferedHTTPClient.ResponseData"
			var content_type = ""
			http_method = http_method.to_upper()
			if responses.has("200"):
				var content =  responses["200"].get("content", {})

				# Assuming the successful response is a JSON object
				result_type = "Dictionary"

				# Special case for /schedule/icalendar
				if content.has("text/calendar"):
					result_type = "BufferedHTTPClient.ResponseData"

				# Try to resolve the component references
				var ref = content.get("application/json", {}).get("schema", {}).get("$ref", "")
				if ref != "":
					result_type = _resolve_ref(ref)

			if method_spec.has("requestBody"):
				var requestBody = method_spec.get("requestBody")
				var content = requestBody.get("content")
				content_type = content.keys()[0]
			elif http_method == "POST":
				content_type = "application/x-www-form-urlencoded"

			var method_data = {
				"summary": summary,
				"description": description,
				"url": url,
				"name": method_name,
				"parameters": parameters["parameters"],
				"all_parameters": parameters["all_parameters"],
				"optional_body_parameters_code": parameters["optional_body_parameters_code"],
				"result_type": result_type,
				"content_type": content_type,
				"request_path": "/helix" + path + "?",
				"method": http_method,
				"header": header_code,
				"body": "body" if has_body else "\"\"",
				"has_return_value": result_type != "BufferedHTTPClient.ResponseData",
				"has_optional": parameters["has_optional"],
				"time_parameters": parameters["time_parameters"],
				"array_parameters": parameters["array_parameters"],
				"query_parameters": parameters["query_params"],
				"time_parameters_opt": parameters["time_parameters_opt"],
				"array_parameters_opt": parameters["array_parameters_opt"],
				"query_parameters_opt": parameters["query_params_opt"],
				"has_broadcaster": parameters["has_broadcaster"]
			}
			data.append(template.parse_template(template_method, method_data))
			if parameters["has_optional"]:
				data.append(template.parse_template(template_parameter_optional, method_data))
			if parameters["has_optional_body"]:
				data.append(template.parse_template(template_body_optional, method_data))

	template.process_template("res://addons/twitcher/editor/api_generator/template_api.txt", {"methods": data}, api_output_path)
	print("Twitch API got generated succesfully into ", api_output_path)


func _parse_parameters(method_spec: Dictionary) -> Dictionary:
	var query_params: Array[String] = []
	var time_parameters = []
	var array_parameters = []
	var query_params_opt: Array[String] = []
	var time_parameters_opt = []
	var array_parameters_opt = []
	var parameters_code = ""
	var all_parameters_code = ""
	var optional_body_parameters_code = ""
	var parameters = method_spec.get("parameters", [])
	var append_broadcaster = false
	var has_body = false
	for param in parameters:
		if param.name == "broadcaster_id":
			query_params.append(param.name)
			append_broadcaster = true
		elif param.in == "query":
			var type = _get_param_type(param["schema"])
			all_parameters_code += "%s: %s, " % [param.name, type]
			if param.get("required", false):
				parameters_code += "%s: %s, " % [param.name, type]
			var schema = param["schema"]
			if schema.get("format", "") == "date-time":
				if param.get("required", false):
					time_parameters.append(param.name)
				else:
					time_parameters_opt.append(param.name)
			if schema.get("type", "") == "array":
				if param.get("required", false):
					array_parameters.append(param.name)
				else:
					array_parameters_opt.append(param.name)
			else:
				if param.get("required", false):
					query_params.append(param.name)
				else:
					query_params_opt.append(param.name)

	optional_body_parameters_code = parameters_code
	if method_spec.has("requestBody"):
		var type = "Dictionary"
		var ref = method_spec.get("requestBody").get("content", {}).get("application/json", {}).get("schema", {}).get("$ref", "")
		if ref != "":
			type = _resolve_ref(ref)
		parameters_code += "body: %s, " % type
		all_parameters_code += "body: %s, " % type
		optional_body_parameters_code += "body: Dictionary, "
		has_body = true


	var has_optional: bool = false
	if not query_params_opt.is_empty() || not time_parameters_opt.is_empty() || not array_parameters_opt.is_empty():
		parameters_code += "optional: Dictionary, "
		optional_body_parameters_code += "optional: Dictionary, "
		has_optional = true

	# Has to be last or atleast within the default parameters at the end
	if append_broadcaster:
		parameters_code += "broadcaster_id: String = \"\", "
		all_parameters_code += "broadcaster_id: String = \"\", "
		optional_body_parameters_code += "broadcaster_id: String = \"\", "

	return {
		"parameters": parameters_code.rstrip(", "),
		"all_parameters": all_parameters_code.rstrip(", "),
		"optional_body_parameters_code": optional_body_parameters_code.rstrip(", "),
		"has_optional": has_optional,
		"has_body": has_body,
		"has_optional_body": has_body,
		"query_params": query_params,
		"time_parameters": time_parameters,
		"array_parameters": array_parameters,
		"query_params_opt": query_params_opt,
		"time_parameters_opt": time_parameters_opt,
		"array_parameters_opt": array_parameters_opt,
		"has_broadcaster": append_broadcaster
	}

#endregion


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
