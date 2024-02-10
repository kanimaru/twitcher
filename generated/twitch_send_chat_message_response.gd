@tool
extends RefCounted

class_name TwitchSendChatMessageResponse

## 
var data: Array;

static func from_json(d: Dictionary) -> TwitchSendChatMessageResponse:
	var result = TwitchSendChatMessageResponse.new();

	for value in d["data"]:
		result.data.append(value);
{elif property.is_typed_array}
	for value in d["data"]:
		result.data.append(.from_json(value));
{elif property.is_sub_class}
	result.data = Array.from_json(d["data"]);
{else}
	result.data = d["data"];

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

