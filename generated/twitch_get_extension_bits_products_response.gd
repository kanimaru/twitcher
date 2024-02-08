@tool
extends RefCounted

class_name TwitchGetExtensionBitsProductsResponse

## A list of Bits products that the extension created. The list is in ascending SKU order. The list is empty if the extension hasn’t created any products or they’re all expired or disabled.
var data: Array[TwitchExtensionBitsProduct];

static func from_json(d: Dictionary) -> TwitchGetExtensionBitsProductsResponse:
	var result = TwitchGetExtensionBitsProductsResponse.new();
	result.data = d["data"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = data;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

