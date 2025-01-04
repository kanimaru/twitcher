@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchChatBadge

## An ID that identifies this set of chat badges. For example, Bits or Subscriber.
var set_id: String:
	set(val):
		set_id = val;
		changed_data["set_id"] = set_id;
## The list of chat badges in this set.
var versions: Array[Versions]:
	set(val):
		versions = val;
		changed_data["versions"] = [];
		if versions != null:
			for value in versions:
				changed_data["versions"].append(value.to_dict());

var changed_data: Dictionary = {};

static func from_json(d: Dictionary) -> TwitchChatBadge:
	var result = TwitchChatBadge.new();
	if d.has("set_id") && d["set_id"] != null:
		result.set_id = d["set_id"];
	if d.has("versions") && d["versions"] != null:
		for value in d["versions"]:
			result.versions.append(Versions.from_json(value));
	return result;

func to_dict() -> Dictionary:
	return changed_data;

func to_json() -> String:
	return JSON.stringify(to_dict());

##
class Versions extends RefCounted:
	## An ID that identifies this version of the badge. The ID can be any value. For example, for Bits, the ID is the Bits tier level, but for World of Warcraft, it could be Alliance or Horde.
	var id: String:
		set(val):
			id = val;
			changed_data["id"] = id;
	## A URL to the small version (18px x 18px) of the badge.
	var image_url_1x: String:
		set(val):
			image_url_1x = val;
			changed_data["image_url_1x"] = image_url_1x;
	## A URL to the medium version (36px x 36px) of the badge.
	var image_url_2x: String:
		set(val):
			image_url_2x = val;
			changed_data["image_url_2x"] = image_url_2x;
	## A URL to the large version (72px x 72px) of the badge.
	var image_url_4x: String:
		set(val):
			image_url_4x = val;
			changed_data["image_url_4x"] = image_url_4x;
	## The title of the badge.
	var title: String:
		set(val):
			title = val;
			changed_data["title"] = title;
	## The description of the badge.
	var description: String:
		set(val):
			description = val;
			changed_data["description"] = description;
	## The action to take when clicking on the badge. Set to `null` if no action is specified.
	var click_action: String:
		set(val):
			click_action = val;
			changed_data["click_action"] = click_action;
	## The URL to navigate to when clicking on the badge. Set to `null` if no URL is specified.
	var click_url: String:
		set(val):
			click_url = val;
			changed_data["click_url"] = click_url;

	var changed_data: Dictionary = {};

	static func from_json(d: Dictionary) -> Versions:
		var result = Versions.new();
		if d.has("id") && d["id"] != null:
			result.id = d["id"];
		if d.has("image_url_1x") && d["image_url_1x"] != null:
			result.image_url_1x = d["image_url_1x"];
		if d.has("image_url_2x") && d["image_url_2x"] != null:
			result.image_url_2x = d["image_url_2x"];
		if d.has("image_url_4x") && d["image_url_4x"] != null:
			result.image_url_4x = d["image_url_4x"];
		if d.has("title") && d["title"] != null:
			result.title = d["title"];
		if d.has("description") && d["description"] != null:
			result.description = d["description"];
		if d.has("click_action") && d["click_action"] != null:
			result.click_action = d["click_action"];
		if d.has("click_url") && d["click_url"] != null:
			result.click_url = d["click_url"];
		return result;

	func to_dict() -> Dictionary:
		return changed_data;

	func to_json() -> String:
		return JSON.stringify(to_dict());
