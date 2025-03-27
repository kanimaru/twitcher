@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/CharityCampaignDonation
class_name TwitchCharityCampaignDonation
	
## An ID that identifies the donation. The ID is unique across campaigns.
@export var id: String:
	set(val): 
		id = val
		track_data(&"id", val)

## An ID that identifies the charity campaign that the donation applies to.
@export var campaign_id: String:
	set(val): 
		campaign_id = val
		track_data(&"campaign_id", val)

## An ID that identifies a user that donated money to the campaign.
@export var user_id: String:
	set(val): 
		user_id = val
		track_data(&"user_id", val)

## The user’s login name.
@export var user_login: String:
	set(val): 
		user_login = val
		track_data(&"user_login", val)

## The user’s display name.
@export var user_name: String:
	set(val): 
		user_name = val
		track_data(&"user_name", val)

## An object that contains the amount of money that the user donated.
@export var amount: Amount:
	set(val): 
		amount = val
		track_data(&"amount", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_id: String, _campaign_id: String, _user_id: String, _user_login: String, _user_name: String, _amount: Amount) -> TwitchCharityCampaignDonation:
	var twitch_charity_campaign_donation: TwitchCharityCampaignDonation = TwitchCharityCampaignDonation.new()
	twitch_charity_campaign_donation.id = _id
	twitch_charity_campaign_donation.campaign_id = _campaign_id
	twitch_charity_campaign_donation.user_id = _user_id
	twitch_charity_campaign_donation.user_login = _user_login
	twitch_charity_campaign_donation.user_name = _user_name
	twitch_charity_campaign_donation.amount = _amount
	return twitch_charity_campaign_donation


static func from_json(d: Dictionary) -> TwitchCharityCampaignDonation:
	var result: TwitchCharityCampaignDonation = TwitchCharityCampaignDonation.new()
	if d.get("id", null) != null:
		result.id = d["id"]
	if d.get("campaign_id", null) != null:
		result.campaign_id = d["campaign_id"]
	if d.get("user_id", null) != null:
		result.user_id = d["user_id"]
	if d.get("user_login", null) != null:
		result.user_login = d["user_login"]
	if d.get("user_name", null) != null:
		result.user_name = d["user_name"]
	if d.get("amount", null) != null:
		result.amount = Amount.from_json(d["amount"])
	return result



## An object that contains the amount of money that the user donated.
## #/components/schemas/CharityCampaignDonation/Amount
class Amount extends TwitchData:

	## The monetary amount. The amount is specified in the currency’s minor unit. For example, the minor units for USD is cents, so if the amount is $5.50 USD, `value` is set to 550.
	@export var value: int:
		set(val): 
			value = val
			track_data(&"value", val)
	
	## The number of decimal places used by the currency. For example, USD uses two decimal places. Use this number to translate `value` from minor units to major units by using the formula:  
	##   
	## `value / 10^decimal_places`
	@export var decimal_places: int:
		set(val): 
			decimal_places = val
			track_data(&"decimal_places", val)
	
	## The ISO-4217 three-letter currency code that identifies the type of currency in `value`.
	@export var currency: String:
		set(val): 
			currency = val
			track_data(&"currency", val)
	
	
	
	## Constructor with all required fields.
	static func create(_value: int, _decimal_places: int, _currency: String) -> Amount:
		var amount: Amount = Amount.new()
		amount.value = _value
		amount.decimal_places = _decimal_places
		amount.currency = _currency
		return amount
	
	
	static func from_json(d: Dictionary) -> Amount:
		var result: Amount = Amount.new()
		if d.get("value", null) != null:
			result.value = d["value"]
		if d.get("decimal_places", null) != null:
			result.decimal_places = d["decimal_places"]
		if d.get("currency", null) != null:
			result.currency = d["currency"]
		return result
	