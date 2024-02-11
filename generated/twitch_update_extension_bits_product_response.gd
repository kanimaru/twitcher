@tool
extends RefCounted

class_name TwitchUpdateExtensionBitsProductResponse

## A list of Bits products that the extension created. The list is in ascending SKU order. The list is empty if the extension hasn't created any products or they're all expired or disabled.
var data: Array[TwitchExtensionBitsProduct];

static func from_json(d: Dictionary) -> TwitchUpdateExtensionBitsProductResponse:
	var result = TwitchUpdateExtensionBitsProductResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchExtensionBitsProduct.from_json(value));
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());
