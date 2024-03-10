@tool
extends Object

class_name TwitchIrcCapabilities

class Capability extends RefCounted:
	var value: String
	var bit_value: int

	func _init(val: String, bit_val: int) -> void:
		value = val;
		bit_value = bit_val;

	func get_name() -> String:
		return value; #.replace("/", "_").replace(".", "_"); TODO CLEANUP

static var COMMANDS = Capability.new("twitch.tv/commands", 1)
static var MEMBERSHIP = Capability.new("twitch.tv/membership", 2)
static var TAGS = Capability.new("twitch.tv/tags", 4)

static func get_all() -> Array[Capability]:
	return [COMMANDS, MEMBERSHIP, TAGS];

static func get_bit_value(caps: Array[TwitchIrcCapabilities.Capability]) -> int:
	var value: int = 0;
	for cap: Capability in caps:
		value |= cap.bit_value;
	return value;
