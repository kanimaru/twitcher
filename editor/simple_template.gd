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
	return content

# Parses the template content and replaces variables and loops with data.
func parse_template(template_content: String, data: Dictionary) -> String:
	var result = template_content

	# Replace variables
	for key in data.keys():
		if typeof(data[key]) == TYPE_ARRAY:
			continue  # Skip arrays, they will be handled in the loop replacement
		result = result.replace("{%s}" % key, str(data[key]))

	# Process loops
	var loop_pattern = "(?s)\n?{for ([^}]+)}(.*?)\n?{/for}"
	var loop_regex = RegEx.new()
	loop_regex.compile(loop_pattern)
	var matches = loop_regex.search(result)
	while matches:
		var array_key = matches.get_string(1)
		var loop_body = matches.get_string(2)
		var loop_result = ""

		if array_key in data and typeof(data[array_key]) == TYPE_ARRAY:
			for item in data[array_key]:
				loop_result += loop_body.replace("{each}", str(item))

		# Replace the entire loop block with the processed loop result
		var loop_block = matches.get_string(0)
		result = result.replace(loop_block, loop_result)

		# Search for the next match
		matches = loop_regex.search(result)

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
