@tool
extends RefCounted

## Logger class that can be enabled and disabled. (Works best with tool scripts)
class_name TwitchLogger

## Name of the logger that will be shown in the logs
var context_name: String
var suffix: String
var enabled : bool
var debug: bool
var color: String


func _init(ctx_name: String, active: bool = false, should_debug: bool = false) -> void:
	context_name = ctx_name
	enabled = active
	debug = should_debug
	color = string_to_hex_color(ctx_name)
	TwitchLoggerManager.register(self)


func is_enabled() -> bool:
	return enabled


func set_enabled(status: bool) -> void:
	enabled = status


func set_suffix(s: String) -> void:
	suffix = "-" + s


## log a message on info level
func i(text: String):
	if is_enabled(): print_rich("%s I[color=%s][%s%s] %s[/color]" % [Time.get_ticks_msec(), color, context_name, suffix, text])
	#else: print(context_name, " is not enabled")


## log a message on error level
func e(text: String):
	if is_enabled(): print_rich("%s E[b][color=%s][%s%s] %s[/color][/b]" % [Time.get_ticks_msec(), color, context_name, suffix, text])
	#else: print(context_name, " is not enabled")


func d(text: String):
	if is_enabled() && debug: print_rich("%s D[i][color=%s][%s%s] %s[/color][/i]" % [Time.get_ticks_msec(), color, context_name, suffix, text])


func string_to_hex_color(text: String) -> String:
	# Hash the text to generate a unique integer
	var hash_value = text.hash()
	var r = hash_value & 0xFF
	var g = (hash_value >> 8) & 0xFF
	var b = (hash_value >> 16) & 0xFF
	const brighten_factor = 1.5
	r = clamp(r * brighten_factor, 0, 255)
	g = clamp(g * brighten_factor, 0, 255)
	b = clamp(b * brighten_factor, 0, 255)
	var red = "%02x" % r
	var green = "%02x" % g
	var blue = "%02x" % b
	return "#" + red + green + blue
