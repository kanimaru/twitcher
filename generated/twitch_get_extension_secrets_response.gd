@tool
extends RefCounted

class_name TwitchGetExtensionSecretsResponse

## The list of shared secrets that the extension created.
var data: Array[TwitchExtensionSecret];

static func from_json(d: Dictionary) -> TwitchGetExtensionSecretsResponse:
	var result = TwitchGetExtensionSecretsResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

