@tool
extends RefCounted

class_name TwitchCreateExtensionSecretResponse

## A list that contains the newly added secrets.
var data: Array[TwitchExtensionSecret];

static func from_json(d: Dictionary) -> TwitchCreateExtensionSecretResponse:
	var result = TwitchCreateExtensionSecretResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

