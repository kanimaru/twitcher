@tool
extends RefCounted

class_name TwitchUpdateExtensionBitsProductBody

## The product's SKU. The SKU must be unique within an extension. The product's SKU cannot be changed. The SKU may contain only alphanumeric characters, dashes (-), underscores (\_), and periods (.) and is limited to a maximum of 255 characters. No spaces.
var sku: String;
## An object that contains the product's cost information.
var cost: UpdateExtensionBitsProductBodyCost;
## The product's name as displayed in the extension. The maximum length is 255 characters.
var display_name: String;
## A Boolean value that indicates whether the product is in development. Set to **true** if the product is in development and not available for public use. The default is **false**.
var in_development: bool;
## The date and time, in RFC3339 format, when the product expires. If not set, the product does not expire. To disable the product, set the expiration date to a date in the past.
var expiration: Variant;
## A Boolean value that determines whether Bits product purchase events are broadcast to all instances of the extension on a channel. The events are broadcast via the `onTransactionComplete` helper callback. The default is **false**.
var is_broadcast: bool;

static func from_json(d: Dictionary) -> TwitchUpdateExtensionBitsProductBody:
	var result = TwitchUpdateExtensionBitsProductBody.new();






	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};


	d["cost"] = cost.to_dict();
{else}
	d["cost"] = cost;





	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the product's cost information.
class UpdateExtensionBitsProductBodyCost extends RefCounted:
	## The product's price.
	var amount: int;
	## The type of currency. Possible values are:      * bits — The minimum price is 1 and the maximum is 10000.
	var type: String;

	static func from_json(d: Dictionary) -> UpdateExtensionBitsProductBodyCost:
		var result = UpdateExtensionBitsProductBodyCost.new();
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

