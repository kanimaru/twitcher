@tool
extends RefCounted

class_name TwitchExtensionTransaction

## An ID that identifies the transaction.
var id: String;
## The UTC date and time (in RFC3339 format) of the transaction.
var timestamp: Variant;
## The ID of the broadcaster that owns the channel where the transaction occurred.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The ID of the user that purchased the digital product.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## The type of transaction. Possible values are:      * BITS\_IN\_EXTENSION
var product_type: String;
## Contains details about the digital product.
var product_data: ExtensionTransactionProductData;

static func from_json(d: Dictionary) -> TwitchExtensionTransaction:
	var result = TwitchExtensionTransaction.new();










	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};










	d["product_data"] = product_data.to_dict();
{else}
	d["product_data"] = product_data;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## Contains details about the digital product.
class ExtensionTransactionProductData extends RefCounted:
	## An ID that identifies the digital product.
	var sku: String;
	## Set to `twitch.ext.` \+ `<the extension's ID>`.
	var domain: String;
	## Contains details about the digital product’s cost.
	var cost: Dictionary;
	## A Boolean value that determines whether the product is in development. Is **true** if the digital product is in development and cannot be exchanged.
	var inDevelopment: bool;
	## The name of the digital product.
	var displayName: String;
	## This field is always empty since you may purchase only unexpired products.
	var expiration: String;
	## A Boolean value that determines whether the data was broadcast to all instances of the extension. Is **true** if the data was broadcast to all instances.
	var broadcast: bool;

	static func from_json(d: Dictionary) -> ExtensionTransactionProductData:
		var result = ExtensionTransactionProductData.new();
		result.sku = d["sku"];
		result.domain = d["domain"];
		result.cost = d["cost"];
		result.inDevelopment = d["inDevelopment"];
		result.displayName = d["displayName"];
		result.expiration = d["expiration"];
		result.broadcast = d["broadcast"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["sku"] = sku;
		d["domain"] = domain;
		d["cost"] = cost;
		d["inDevelopment"] = inDevelopment;
		d["displayName"] = displayName;
		d["expiration"] = expiration;
		d["broadcast"] = broadcast;
		return d;

