@tool
extends TwitchData

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

## 
## #/components/schemas/Cheermote
class_name TwitchCheermote
	
## The name portion of the Cheermote string that you use in chat to cheer Bits. The full Cheermote string is the concatenation of {prefix} + {number of Bits}. For example, if the prefix is “Cheer” and you want to cheer 100 Bits, the full Cheermote string is Cheer100\. When the Cheermote string is entered in chat, Twitch converts it to the image associated with the Bits tier that was cheered.
var prefix: String:
	set(val): 
		prefix = val
		track_data(&"prefix", val)

## A list of tier levels that the Cheermote supports. Each tier identifies the range of Bits that you can cheer at that tier level and an image that graphically identifies the tier level.
var tiers: Array[Tiers]:
	set(val): 
		tiers = val
		track_data(&"tiers", val)

## The type of Cheermote. Possible values are:  
##   
## * global\_first\_party — A Twitch-defined Cheermote that is shown in the Bits card.
## * global\_third\_party — A Twitch-defined Cheermote that is not shown in the Bits card.
## * channel\_custom — A broadcaster-defined Cheermote.
## * display\_only — Do not use; for internal use only.
## * sponsored — A sponsor-defined Cheermote. When used, the sponsor adds additional Bits to the amount that the user cheered. For example, if the user cheered Terminator100, the broadcaster might receive 110 Bits, which includes the sponsor's 10 Bits contribution.
var type: String:
	set(val): 
		type = val
		track_data(&"type", val)

## The order that the Cheermotes are shown in the Bits card. The numbers may not be consecutive. For example, the numbers may jump from 1 to 7 to 13\. The order numbers are unique within a Cheermote type (for example, global\_first\_party) but may not be unique amongst all Cheermotes in the response.
var order: int:
	set(val): 
		order = val
		track_data(&"order", val)

## The date and time, in RFC3339 format, when this Cheermote was last updated.
var last_updated: Variant:
	set(val): 
		last_updated = val
		track_data(&"last_updated", val)

## A Boolean value that indicates whether this Cheermote provides a charitable contribution match during charity campaigns.
var is_charitable: bool:
	set(val): 
		is_charitable = val
		track_data(&"is_charitable", val)
var response: BufferedHTTPClient.ResponseData


## Constructor with all required fields.
static func create(_prefix: String, _tiers: Array[Tiers], _type: String, _order: int, _last_updated: Variant, _is_charitable: bool) -> TwitchCheermote:
	var twitch_cheermote: TwitchCheermote = TwitchCheermote.new()
	twitch_cheermote.prefix = _prefix
	twitch_cheermote.tiers = _tiers
	twitch_cheermote.type = _type
	twitch_cheermote.order = _order
	twitch_cheermote.last_updated = _last_updated
	twitch_cheermote.is_charitable = _is_charitable
	return twitch_cheermote


static func from_json(d: Dictionary) -> TwitchCheermote:
	var result: TwitchCheermote = TwitchCheermote.new()
	if d.get("prefix", null) != null:
		result.prefix = d["prefix"]
	if d.get("tiers", null) != null:
		for value in d["tiers"]:
			result.tiers.append(Tiers.from_json(value))
	if d.get("type", null) != null:
		result.type = d["type"]
	if d.get("order", null) != null:
		result.order = d["order"]
	if d.get("last_updated", null) != null:
		result.last_updated = d["last_updated"]
	if d.get("is_charitable", null) != null:
		result.is_charitable = d["is_charitable"]
	return result



## A list of tier levels that the Cheermote supports. Each tier identifies the range of Bits that you can cheer at that tier level and an image that graphically identifies the tier level.
## #/components/schemas/Cheermote/Tiers
class Tiers extends TwitchData:

	## The minimum number of Bits that you must cheer at this tier level. The maximum number of Bits that you can cheer at this level is determined by the required minimum Bits of the next tier level minus 1\. For example, if `min_bits` is 1 and `min_bits` for the next tier is 100, the Bits range for this tier level is 1 through 99\. The minimum Bits value of the last tier is the maximum number of Bits you can cheer using this Cheermote. For example, 10000.
	var min_bits: int:
		set(val): 
			min_bits = val
			track_data(&"min_bits", val)
	
	## The tier level. Possible tiers are:  
	##   
	## * 1
	## * 100
	## * 500
	## * 1000
	## * 5000
	## * 10000
	## * 100000
	var id: String:
		set(val): 
			id = val
			track_data(&"id", val)
	
	## The hex code of the color associated with this tier level (for example, #979797).
	var color: String:
		set(val): 
			color = val
			track_data(&"color", val)
	
	## 
	var images: TwitchCheermoteImages:
		set(val): 
			images = val
			track_data(&"images", val)
	
	## A Boolean value that determines whether users can cheer at this tier level.
	var can_cheer: bool:
		set(val): 
			can_cheer = val
			track_data(&"can_cheer", val)
	
	## A Boolean value that determines whether this tier level is shown in the Bits card. Is **true** if this tier level is shown in the Bits card.
	var show_in_bits_card: bool:
		set(val): 
			show_in_bits_card = val
			track_data(&"show_in_bits_card", val)
	
	
	
	## Constructor with all required fields.
	static func create(_min_bits: int, _id: String, _color: String, _images: TwitchCheermoteImages, _can_cheer: bool, _show_in_bits_card: bool) -> Tiers:
		var tiers: Tiers = Tiers.new()
		tiers.min_bits = _min_bits
		tiers.id = _id
		tiers.color = _color
		tiers.images = _images
		tiers.can_cheer = _can_cheer
		tiers.show_in_bits_card = _show_in_bits_card
		return tiers
	
	
	static func from_json(d: Dictionary) -> Tiers:
		var result: Tiers = Tiers.new()
		if d.get("min_bits", null) != null:
			result.min_bits = d["min_bits"]
		if d.get("id", null) != null:
			result.id = d["id"]
		if d.get("color", null) != null:
			result.color = d["color"]
		if d.get("images", null) != null:
			result.images = TwitchCheermoteImages.from_json(d["images"])
		if d.get("can_cheer", null) != null:
			result.can_cheer = d["can_cheer"]
		if d.get("show_in_bits_card", null) != null:
			result.show_in_bits_card = d["show_in_bits_card"]
		return result
	