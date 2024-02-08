@tool
extends RefCounted

class_name TwitchExtensionBitsProduct

## The product's SKU. The SKU is unique across an extension's products.
var sku: String;
## An object that contains the product's cost information.
var cost: ExtensionBitsProductCost;
## A Boolean value that indicates whether the product is in development. If **true**, the product is not available for public use.
var in_development: bool;
## The product's name as displayed in the extension.
var display_name: String;
## The date and time, in RFC3339 format, when the product expires.
var expiration: Variant;
## A Boolean value that determines whether Bits product purchase events are broadcast to all instances of an extension on a channel. The events are broadcast via the `onTransactionComplete` helper callback. Is **true** if the event is broadcast to all instances.
var is_broadcast: bool;

static func from_json(d: Dictionary) -> TwitchExtensionBitsProduct:
	var result = TwitchExtensionBitsProduct.new();
	result.sku = d["sku"];

	result.cost = ExtensionBitsProductCost.from_json(d["cost"]);

	result.in_development = d["in_development"];
	result.display_name = d["display_name"];
	result.expiration = d["expiration"];
	result.is_broadcast = d["is_broadcast"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["sku"] = sku;

	d["cost"] = cost.to_dict();

	d["in_development"] = in_development;
	d["display_name"] = display_name;
	d["expiration"] = expiration;
	d["is_broadcast"] = is_broadcast;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the product's cost information.
class ExtensionBitsProductCost extends RefCounted:
	## The product's price.
	var amount: int;
	## The type of currency. Possible values are:      * bits
	var type: String;

	static func from_json(d: Dictionary) -> ExtensionBitsProductCost:
		var result = ExtensionBitsProductCost.new();
		result.amount = d["amount"];
		result.type = d["type"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["amount"] = amount;
		d["type"] = type;
		return d;

