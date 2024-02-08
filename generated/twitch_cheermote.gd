@tool
extends RefCounted

class_name TwitchCheermote

## The name portion of the Cheermote string that you use in chat to cheer Bits. The full Cheermote string is the concatenation of {prefix} + {number of Bits}. For example, if the prefix is “Cheer” and you want to cheer 100 Bits, the full Cheermote string is Cheer100\. When the Cheermote string is entered in chat, Twitch converts it to the image associated with the Bits tier that was cheered.
var prefix: String;
## A list of tier levels that the Cheermote supports. Each tier identifies the range of Bits that you can cheer at that tier level and an image that graphically identifies the tier level.
var tiers: Array;
## The type of Cheermote. Possible values are:      * global\_first\_party — A Twitch-defined Cheermote that is shown in the Bits card. * global\_third\_party — A Twitch-defined Cheermote that is not shown in the Bits card. * channel\_custom — A broadcaster-defined Cheermote. * display\_only — Do not use; for internal use only. * sponsored — A sponsor-defined Cheermote. When used, the sponsor adds additional Bits to the amount that the user cheered. For example, if the user cheered Terminator100, the broadcaster might receive 110 Bits, which includes the sponsor's 10 Bits contribution.
var type: String;
## The order that the Cheermotes are shown in the Bits card. The numbers may not be consecutive. For example, the numbers may jump from 1 to 7 to 13\. The order numbers are unique within a Cheermote type (for example, global\_first\_party) but may not be unique amongst all Cheermotes in the response.
var order: int;
## The date and time, in RFC3339 format, when this Cheermote was last updated.
var last_updated: Variant;
## A Boolean value that indicates whether this Cheermote provides a charitable contribution match during charity campaigns.
var is_charitable: bool;

static func from_json(d: Dictionary) -> TwitchCheermote:
	var result = TwitchCheermote.new();
	result.prefix = d["prefix"];
	result.tiers = d["tiers"];
	result.type = d["type"];
	result.order = d["order"];
	result.last_updated = d["last_updated"];
	result.is_charitable = d["is_charitable"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["prefix"] = prefix;
	d["tiers"] = tiers;
	d["type"] = type;
	d["order"] = order;
	d["last_updated"] = last_updated;
	d["is_charitable"] = is_charitable;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

