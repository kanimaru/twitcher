@tool
extends RefCounted

class_name TwitchUpdateShieldModeStatusBody

## A Boolean value that determines whether to activate Shield Mode. Set to **true** to activate Shield Mode; otherwise, **false** to deactivate Shield Mode.
var is_active: bool;

static func from_json(d: Dictionary) -> TwitchUpdateShieldModeStatusBody:
	var result = TwitchUpdateShieldModeStatusBody.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

