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
    var out = generate_gdscript_methods(definition);
    template.write_output_file("res://addons/twitcher/api/repo.gd", out)

func _get_repository_methods(definition: Dictionary) -> Array[Dictionary]:
    var data: Array[Dictionary] = [];
    var paths = definition['paths'];
    for path: String in paths:
        var method_data = {};
        data.append(method_data);

        var path_data = paths[path];
        for method in path_data:
            var method_details = path_data[method]
            var method_name = method_details['operationId'].replace("-", "_");
            method_data['method_name'] = method_name;
            method_data['summary'] = method_details['summary'];
    return data;

func generate_gdscript_methods(openapi_spec: Dictionary):
    var gdscript_code := ""
    var paths = openapi_spec.get("paths", {})
    for path in paths:
        var methods = paths[path];
        for http_method: String in methods:
            var method_spec = methods[http_method];
            var method_name = method_spec.get("operationId", "method_" + http_method).replace("-", "_")
            var summary = method_spec.get("summary", "No summary provided.")
            var parameters_code = ""
            var header_code = "{}"
            var body_code = "null"
            var parameters = method_spec.get("parameters", [])
            for param in parameters:
                if param.get("in") == "header":
                    header_code = "{ \"%s\": %s }" % [param.name, param.name]
                elif param.get("in") == "body":
                    body_code = param.name
                else:
                    parameters_code += "%s, " % param.name
            var responses = method_spec.get("responses", {})
            var result_type = "void"
            if responses.has("200"):
                result_type = "Dictionary"  # Assuming the successful response is a JSON object
            gdscript_code += "\n# %s\nfunc %s(%s) -> %s:\n" % [summary, method_name, parameters_code.rstrip(", "), result_type]
            gdscript_code += "\tvar response = await request(\"%s\", HTTPClient.METHOD_%s, %s, %s)\n" % [path, http_method.to_upper(), header_code, body_code]

            if result_type != "void":
                gdscript_code += "\tvar result = JSON.parse_string(response.response_data.get_string_from_utf8())\n"
                gdscript_code += "\treturn result\n"
    return gdscript_code
