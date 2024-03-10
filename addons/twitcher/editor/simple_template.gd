@tool
extends RefCounted

class_name SimpleTemplate

# Processes the template file with the given data and writes to the output file.
func process_template(file_path: String, data: Dictionary, file_output: String) -> void:
	var template_content = read_template_file(file_path)
	var processed_content = parse_template(template_content, data)
	write_output_file(file_output, processed_content)

# Reads the template file and returns its content.
func read_template_file(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ);
	if file == null:
		push_error("Failed to open template file: %s" % file_path)
		return ""
	var content = file.get_as_text()
	file.close()
	return content.strip_edges()

# Parses the template content and replaces variables, loops, and conditions with data.
func parse_template(template_content: String, data: Dictionary) -> String:
	var result = template_content
	result = _parse_variables(result, data);
	result = _parse_loops(result, data);
	result = _parse_conditionals(result, data);
	return result

# Helper function to retrieve nested values from a dictionary
func _get_nested_value(data: Dictionary, keys: PackedStringArray) -> Variant:
	var current_data = data
	for key in keys:
		if current_data.has(key):
			current_data = current_data[key]
		else:
			return null
	return current_data

# Replaces variables with support for nested data
func _parse_variables(result: String, data: Dictionary, variable_pattern = "{([a-zA-Z0-9_.]+)}") -> String:
	var variable_regex = RegEx.create_from_string(variable_pattern)
	var matches = variable_regex.search(result)
	while matches:
		var full_match = matches.get_string(0)
		var variable_path = matches.get_string(1).split(".")
		var value = _get_nested_value(data, variable_path)
		var value_length = 0;
		if value != null:
			var txt_value = str(value)
			result = result.replace(full_match, txt_value)
			value_length = txt_value.length() - full_match.length()
		matches = variable_regex.search(result, matches.get_end() + value_length)
	return result

# Process loops
# TODO Nested for loops not supported -> the /for is tracked to early in regex
func _parse_loops(result: String, data: Dictionary) -> String:
	var loop_regex = RegEx.create_from_string("(?s){for (.*?) as (.*?)}\r?\n(.*?){/for}\r?\n?");
	var matches: RegExMatch = loop_regex.search(result);
	while matches:
		var variable_path = matches.get_string(1).split(".")
		var each_name = matches.get_string(2)
		var loop_body = matches.get_string(3)
		var loop_result = ""

		var loop_data = _get_nested_value(data, variable_path)
		if loop_data != null and typeof(loop_data) == TYPE_ARRAY:
			for item in loop_data:
				loop_result += parse_template(loop_body,  {each_name: item})

		# Replace the entire loop block with the processed loop result
		var loop_block = matches.get_string(0)
		result = result.replace(loop_block, loop_result)

		# Search for the next match
		matches = loop_regex.search(result)
	return result;

class Condition extends RefCounted:
	var expression: String;
	var content: String;
	var expression_is_true: bool;

	func _init(exp: String, cont: String):
		expression = exp;
		content = cont;

# Process conditionals with support for nested data and elif statements
func _parse_conditionals(result: String, data: Dictionary) -> String:
	var conditional_regex = RegEx.create_from_string("(?s){if ([^}]+)}\r?\n?([^{]+)(\r?\n?{else}\r?\n?(.*?))?\r?\n?{/if}\r?\n?")
	var matches = conditional_regex.search(result)
	while matches:
		var variable_path = matches.get_string(1).split(".")
		var true_body = matches.get_string(2)
		var false_body = matches.get_string(4) # Capture group for the "else" clause content
		var conditional_result = ""

		var conditional_data = _get_nested_value(data, variable_path)
		if conditional_data != null and bool(conditional_data):
			conditional_result = parse_template(true_body, data)
		elif false_body != null:
			conditional_result = parse_template(false_body, data)

		# Replace the entire conditional block with the processed conditional result or an empty string
		var conditional_block = matches.get_string(0)
		result = result.replace(conditional_block, conditional_result)

		matches = conditional_regex.search(result)
	return result

# Writes the processed content to the output file.
func write_output_file(file_output: String, content: String) -> void:
	var file = FileAccess.open(file_output, FileAccess.WRITE);
	if file == null:
		var error_message = error_string(FileAccess.get_open_error());
		push_error("Failed to open output file: %s\n%s" % [file_output, error_message])
		return
	file.store_string(content)
	file.close()
