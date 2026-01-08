## This one should be Godot Core but isn't sadly...
class_name RegexUtil

static func escape(input:String) -> String:
	input = input.replace("\\", "\\\\")
	input = input.replace(".", "\\.")
	input = input.replace("^", "\\^")
	input = input.replace("$", "\\$")
	input = input.replace("*", "\\*")
	input = input.replace("+", "\\+")
	input = input.replace("?", "\\?")
	input = input.replace("(", "\\(")
	input = input.replace(")", "\\)")
	input = input.replace("[", "\\[")
	input = input.replace("]", "\\]")
	input = input.replace("{", "\\{")
	input = input.replace("}", "\\}")
	input = input.replace("|", "\\|")
	return input
