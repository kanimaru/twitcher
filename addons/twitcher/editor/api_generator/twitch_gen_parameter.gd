@tool
extends TwitchGen

class_name TwitchGenParameter
var _name: String
var _description: String
var _required: bool
var _type: String
var _is_time: bool
var _is_array: bool

static func sort(p1: TwitchGenParameter, p2: TwitchGenParameter) -> bool:
	if p1._name == "broadcaster_id":
		return false
	if p2._name == "broadcaster_id":
		return true
	if p1._required && not p2._required:
		return true
	if not p1._required && p2._required:
		return false
	return p1._name < p2._name
		
