@tool
extends RefCounted

class_name TwitchCharityCampaign

## An ID that identifies the charity campaign.
var id: String;
## An ID that identifies the broadcaster that’s running the campaign.
var broadcaster_id: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var broadcaster_name: String;
## The charity’s name.
var charity_name: String;
## A description of the charity.
var charity_description: String;
## A URL to an image of the charity’s logo. The image’s type is PNG and its size is 100px X 100px.
var charity_logo: String;
## A URL to the charity’s website.
var charity_website: String;
## The current amount of donations that the campaign has received.
var current_amount: CharityCampaignCurrentAmount;
## The campaign’s fundraising goal. This field is **null** if the broadcaster has not defined a fundraising goal.
var target_amount: CharityCampaignTargetAmount;

static func from_json(d: Dictionary) -> TwitchCharityCampaign:
	var result = TwitchCharityCampaign.new();










	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};









	d["current_amount"] = current_amount.to_dict();
{else}
	d["current_amount"] = current_amount;


	d["target_amount"] = target_amount.to_dict();
{else}
	d["target_amount"] = target_amount;

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The current amount of donations that the campaign has received.
class CharityCampaignCurrentAmount extends RefCounted:
	## The monetary amount. The amount is specified in the currency’s minor unit. For example, the minor units for USD is cents, so if the amount is $5.50 USD, `value` is set to 550.
	var value: int;
	## The number of decimal places used by the currency. For example, USD uses two decimal places. Use this number to translate `value` from minor units to major units by using the formula:      `value / 10^decimal_places`
	var decimal_places: int;
	## The ISO-4217 three-letter currency code that identifies the type of currency in `value`.
	var currency: String;

	static func from_json(d: Dictionary) -> CharityCampaignCurrentAmount:
		var result = CharityCampaignCurrentAmount.new();
		result.value = d["value"];
		result.decimal_places = d["decimal_places"];
		result.currency = d["currency"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["value"] = value;
		d["decimal_places"] = decimal_places;
		d["currency"] = currency;
		return d;

## The campaign’s fundraising goal. This field is **null** if the broadcaster has not defined a fundraising goal.
class CharityCampaignTargetAmount extends RefCounted:
	## The monetary amount. The amount is specified in the currency’s minor unit. For example, the minor units for USD is cents, so if the amount is $5.50 USD, `value` is set to 550.
	var value: int;
	## The number of decimal places used by the currency. For example, USD uses two decimal places. Use this number to translate `value` from minor units to major units by using the formula:      `value / 10^decimal_places`
	var decimal_places: int;
	## The ISO-4217 three-letter currency code that identifies the type of currency in `value`.
	var currency: String;

	static func from_json(d: Dictionary) -> CharityCampaignTargetAmount:
		var result = CharityCampaignTargetAmount.new();
		result.value = d["value"];
		result.decimal_places = d["decimal_places"];
		result.currency = d["currency"];
		return result;

	func to_json() -> String:
		return JSON.stringify(to_dict());

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["value"] = value;
		d["decimal_places"] = decimal_places;
		d["currency"] = currency;
		return d;

