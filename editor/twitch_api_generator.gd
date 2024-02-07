@tool
extends Button

class_name Generator

const SWAGGER_API = "https://twitch-api-swagger.surge.sh"

var client: BufferedHTTPClient;
var definition: Dictionary = {};

func _pressed() -> void:
	if definition == {}:
		print("load Twitch definition")
		definition = await _load_swagger_definition();
	_generate_repositories(definition);

func _load_swagger_definition() -> Dictionary:
	client = BufferedHTTPClient.new(SWAGGER_API);
	client.max_error_count = 3;
	var request = client.request("/openapi.json", HTTPClient.METHOD_GET, {}, "");
	var response_data = await client.wait_for_request(request);

	if response_data.error:
		printerr("Can't generate REST API");
	var response_str = response_data.response_data.get_string_from_utf8()
	var response = JSON.parse_string(response_str);
	return response;

func _generate_repositories(definition: Dictionary):
	var template = SimpleTemplate.new()
	#var repo_template = template.read_template_file("./template_repository.txt");
	#var repo_methods = _get_repository_methods(definition);
	#print(template.parse_template(file, template_data));
	generate_gdscript_methods(definition);
	print("API got generated");

func _get_repository_methods(definition: Dictionary) -> Array[Dictionary]:
	var data: Array[Dictionary] = [];
	var paths = definition["paths"];
	for path: String in paths:
		var method_data = {};
		data.append(method_data);

		var path_data = paths[path];
		for method in path_data:
			var method_details = path_data[method]
			var method_name = method_details["operationId"].replace("-", "_");
			method_data["method_name"] = method_name;
			method_data["summary"] = method_details["summary"];
	return data;

func generate_gdscript_methods(openapi_spec: Dictionary):
	var template = SimpleTemplate.new();
	var time_conversion = template.read_template_file("res://addons/twitcher/editor/template_time_conversion.txt");
	var gdscript_code := ""
	var paths = openapi_spec.get("paths", {})
	var data = [];
	for path in paths:
		var methods = paths[path];
		for http_method: String in methods:
			var method_spec = methods[http_method] as Dictionary;
			var method_name = method_spec.get("operationId", "method_" + http_method).replace("-", "_")
			var summary = method_spec.get("summary", "No summary provided.")
			var parameters = _parse_parameters(method_spec)
			var parameters_code = parameters["parameters_code"];
			var has_body = parameters["has_body"];
			var header_code = "{}"
			var responses = method_spec.get("responses", {})
			var result_type = "void"
			http_method = http_method.to_upper()
			if responses.has("200"):
				result_type = "Dictionary"  # Assuming the successful response is a JSON object
			var request_path = _generate_request_path(path, parameters["query_params"])

			data.append({
				"summary": summary,
				"name": method_name,
				"parameters": parameters_code,
				"result_type": result_type,
				"request_path": request_path,
				"method": http_method,
				"header": header_code,
				"body": "body" if has_body else "",
				"has_return_value": result_type != "void",
				"time_parameter": template.parse_template(time_conversion, {"time_parameters": parameters["time_parameters"]})
			})

	template.process_template("res://addons/twitcher/editor/template_method.txt", {'methods': data}, "res://addons/twitcher/generated/twitch_rest_api.gd")

func _parse_parameters(method_spec: Dictionary) -> Dictionary:
	var query_params: Array[String] = [];
	var parameters_code = ""
	var parameters = method_spec.get("parameters", [])
	var append_broadcaster = false
	var has_body = false
	var time_parameters = []
	for param in parameters:
		if param.name == "broadcaster_id":
			append_broadcaster = true
		elif param.in == "query":
			var type = _get_param_type(param);
			parameters_code += "%s: %s, " % [param.name, type]
			query_params.append(param.name)
			if param["schema"].get("format", "") == "date-time":
				time_parameters.append(param.name)

	if method_spec.has("requestBody"):
		parameters_code += "body: Dictionary, "
		has_body = true

	# Has to be last or atleast within the default parameters at the end
	if append_broadcaster:
		parameters_code += "broadcaster_id: String = TwitchSetting.broadcaster_id, "

	return {
		"parameters_code": parameters_code.rstrip(", "),
		"has_body": has_body,
		"query_params": query_params,
		"time_parameters": time_parameters
	}

func _get_param_type(param: Dictionary) -> String:
	var type = param["schema"]["type"];
	var format = param["schema"].get("format", "")
	match type:
		"string":
			if format == "date-time":
				return "Variant";
			return "String"
		"integer":
			return "int";
		_: return "Variant";

## Builds queries to this form: ?broadcaster_id=%s" % [broadcaster_id]
# Hate myself for this method sorry =__=
func _generate_request_path(path: String, query_params: Array[String]) -> String:
	if query_params.is_empty():
		return "\"%s\"" % path;
	var query = "&".join(query_params.map(func(p): return p + "=%s"));
	return "\"" + path + "?" + query + "\" % [" + ",".join(query_params) + "]"
