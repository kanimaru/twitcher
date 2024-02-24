@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCharityCampaignDonation

## An ID that identifies the donation. The ID is unique across campaigns.
var id: String;
## An ID that identifies the charity campaign that the donation applies to.
var campaign_id: String;
## An ID that identifies a user that donated money to the campaign.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## An object that contains the amount of money that the user donated.
var amount: Amount;

static func from_json(d: Dictionary) -> TwitchCharityCampaignDonation:
	var result = TwitchCharityCampaignDonation.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("campaign_id") && d["campaign_id"] != null:
		result.campaign_id = d["campaign_id"];
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("user_login") && d["user_login"] != null:
		result.user_login = d["user_login"];
	if d.has("user_name") && d["user_name"] != null:
		result.user_name = d["user_name"];
	if d.has("amount") && d["amount"] != null:
		result.amount = Amount.from_json(d["amount"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["campaign_id"] = campaign_id;
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	if amount != null:
		d["amount"] = amount.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the amount of money that the user donated.
class Amount extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Amount:
		var result = Amount.new();
{for properties as property}
{if property.is_property_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append(value);
{/if}
{if property.is_property_typed_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append({property.array_type}.from_json(value));
{/if}
{if property.is_property_sub_class}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = {property.type}.from_json(d["{property.property_name}"]);
{/if}
{if property.is_property_basic}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = d["{property.property_name}"];
{/if}
{/for}
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
{for properties as property}
{if property.is_property_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value);
{/if}
{if property.is_property_typed_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value.to_dict());
{/if}
{if property.is_property_sub_class}
		if {property.field_name} != null:
			d["{property.property_name}"] = {property.field_name}.to_dict();
{/if}
{if property.is_property_basic}
		d["{property.property_name}"] = {property.field_name};
{/if}
{/for}
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

