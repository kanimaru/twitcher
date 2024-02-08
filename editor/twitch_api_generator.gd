@tool
extends Button

## Please do not touch! Insane code ahead! Last Warning!
class_name Generator

const SWAGGER_API = "https://twitch-api-swagger.surge.sh"
const api_output_path = "res://addons/twitcher/generated/twitch_rest_api.gd"

var client: BufferedHTTPClient;
var definition: Dictionary = {};

func _pressed() -> void:
	if definition == {}:
		print("load Twitch definition")
		definition = await _load_swagger_definition();
	_generate_repositories();
	_generate_components();

#region Repository

func _load_swagger_definition() -> Dictionary:
	client = BufferedHTTPClient.new(SWAGGER_API);
	client.max_error_count = 3;
	var request = client.request("/openapi.json", HTTPClient.METHOD_GET, {}, "");
	var response_data = await client.wait_for_request(request);

	if response_data.error:
		printerr("Cant generate REST API");
	var response_str = response_data.response_data.get_string_from_utf8()
	var response = JSON.parse_string(response_str);
	return response;

func _generate_repositories():
	var template = SimpleTemplate.new();
	var template_method = template.read_template_file("res://addons/twitcher/editor/template_method.txt");
	var gdscript_code := ""
	var paths = definition.get("paths", {})
	var data = [];
	for path in paths:
		var methods = paths[path];
		for http_method: String in methods:
			var method_spec = methods[http_method] as Dictionary;
			var method_name = method_spec.get("operationId", "method_" + http_method).replace("-", "_")
			var summary = method_spec.get("summary", "No summary provided.")
			var description = method_spec.get("description", "No description provided.")
			var url = method_spec.get("externalDocs", {}).get("url", "No link provided")
			var parameters = _parse_parameters(method_spec)
			var parameters_code = parameters["parameters_code"];
			var has_body = parameters["has_body"];
			var header_code = "{}"
			var responses = method_spec.get("responses", {})
			var result_type = "BufferedHTTPClient.ResponseData"
			http_method = http_method.to_upper()
			if responses.has("200"):
				result_type = "Dictionary"  # Assuming the successful response is a JSON object
				var ref = responses["200"].get("content", {}).get("application/json", {}).get("schema", {}).get("$ref", "")
				if ref != "":
					result_type = _resolve_ref(ref);

			var method_data = {
				"summary": summary,
				"description": description,
				"url": url,
				"name": method_name,
				"parameters": parameters_code,
				"result_type": result_type,
				"request_path": "/helix" + path + "?",
				"method": http_method,
				"header": header_code,
				"body": "body" if has_body else "\"\"",
				"has_return_value": result_type != "BufferedHTTPClient.ResponseData",
				"time_parameters": parameters["time_parameters"],
				"array_parameters": parameters["array_parameters"],
				"query_parameters": parameters["query_params"]
			};
			var method_code = template.parse_template(template_method, method_data)
			data.append(method_code)
	template.process_template("res://addons/twitcher/editor/template_api.txt", {"methods": data}, api_output_path)
	print("Twitch API got generated succesfullt into ", api_output_path);

func _parse_parameters(method_spec: Dictionary) -> Dictionary:
	var query_params: Array[String] = [];
	var parameters_code = ""
	var parameters = method_spec.get("parameters", [])
	var append_broadcaster = false
	var has_body = false
	var time_parameters = []
	var array_parameters = []
	for param in parameters:
		if param.name == "broadcaster_id":
			query_params.append(param.name)
			append_broadcaster = true
		elif param.in == "query":
			var type = _get_param_type(param["schema"]);
			parameters_code += "%s: %s, " % [param.name, type]
			var schema = param["schema"];
			if schema.get("format", "") == "date-time":
				time_parameters.append(param.name)
			if schema.get("type", "") == "array":
				array_parameters.append(param.name)
			else:
				query_params.append(param.name)

	if method_spec.has("requestBody"):
		var type = "Dictionary";
		var ref = method_spec.get("requestBody").get("content", {}).get("application/json", {}).get("schema", {}).get("$ref", "")
		if ref != "":
			type = _resolve_ref(ref);
		parameters_code += "body: %s, " % type
		has_body = true

	# Has to be last or atleast within the default parameters at the end
	if append_broadcaster:
		parameters_code += "broadcaster_id: String = TwitchSetting.broadcaster_id, "

	return {
		"parameters_code": parameters_code.rstrip(", "),
		"has_body": has_body,
		"query_params": query_params,
		"time_parameters": time_parameters,
		"array_parameters": array_parameters
	}

func _resolve_ref(ref: String) -> String:
	return "Twitch" + ref.substr(ref.rfind("/") + 1);

func _get_param_type(schema: Dictionary) -> String:
	if schema.has("$ref"):
		return _resolve_ref(schema["$ref"]);

	if not schema.has("type"):
		return "Variant" # Maybe ugly

	var type = schema["type"];
	var format = schema.get("format", "");
	match type:
		"object":
			if schema.has("additinalProperties"):
				return _get_param_type(schema["additinalProperties"])
			return "Dictionary"
		"string":
			if format == "date-time":
				return "Variant";
			return "String";
		"integer":
			return "int";
		"boolean":
			return "bool";
		"array":
			var ref: String = schema["items"].get("$ref", "");
			if schema["items"].get("type", "") == "string":
				return "Array[String]";
			elif ref != "":
				var ref_name = _resolve_ref(ref);
				return "Array[%s]" % ref_name;
			else:
				return "Array";
		_: return "Variant";

#endregion

func _generate_components():
	var template = SimpleTemplate.new();
	var schemas = definition["components"]["schemas"];
	for schema_name in schemas:
		var classes = [];
		var properties: Array[Dictionary] = [];
		_calculate_template(schema_name, schemas[schema_name], classes, properties)
		var data: Dictionary = {
			"class_name": "Twitch" + schema_name,
			"properties": properties,
			"classes": classes
		}
		var file_name : String = "Twitch" + schema_name + ".gd";
		file_name = file_name.to_snake_case();
		template.process_template("res://addons/twitcher/editor/template_component.txt",
				data, "res://addons/twitcher/generated/" + file_name);

func _calculate_template(schema_name: String, schema: Dictionary, result_classes: Array, result_properties: Array[Dictionary]):
	if schema["type"] != "object":
		printerr("Not an object");
	var properties = schema["properties"];
	for property_name in properties:
		var property = properties[property_name];
		var type = _get_param_type(property)
		var is_sub_class = false
		if property.has("properties"):
			var class_description = property['description'].replace("\n", " ");
			var sub_class = _get_sub_classes(schema_name, property_name, property['properties'], class_description);
			result_classes.append(sub_class["code"]);
			type = sub_class["name"];
			is_sub_class = true;

		result_properties.append({
			"name": property_name,
			"type": type,
			"is_sub_class": is_sub_class,
			"description": property.get("description", "No description available").replace("\n", " "),
		})

func _get_sub_classes(schema_name: String, parent_property_name:String, properties: Dictionary, class_description: String = "") -> Dictionary:
	var template = SimpleTemplate.new()
	var template_component_class = template.read_template_file(
			"res://addons/twitcher/editor/template_component_class.txt");
	var property_data = [];
	for property_name in properties:
		var property = properties[property_name];
		var description = property.get("description", "No description available").replace("\n", " ");
		property_data.append({
			"name": property_name,
			"type": _get_param_type(property),
			"description": description,
		})

	var cls_name = schema_name + parent_property_name.capitalize().replace(" ", "");
	var data = {
		"class_name": cls_name,
		"class_description": class_description,
		"properties": property_data
	};
	return {
		"name": cls_name,
		"code": template.parse_template(template_component_class, data)
	}
