@tool
extends RefCounted

class_name TwitchGetGuestStarInvitesResponse

## A list of invite objects describing the invited user as well as their ready status.
var data: Array[TwitchGuestStarInvite];

static func from_json(d: Dictionary) -> TwitchGetGuestStarInvitesResponse:
	var result = TwitchGetGuestStarInvitesResponse.new();

	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};

	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

