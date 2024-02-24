@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchTeam

## The list of team members.
var users: Array[Users];
## A URL to the team’s background image.
var background_image_url: String;
## A URL to the team’s banner.
var banner: String;
## The UTC date and time (in RFC3339 format) of when the team was created.
var created_at: Variant;
## The UTC date and time (in RFC3339 format) of the last time the team was updated.
var updated_at: Variant;
## The team’s description. The description may contain formatting such as Markdown, HTML, newline (\\n) characters, etc.
var info: String;
## A URL to a thumbnail image of the team’s logo.
var thumbnail_url: String;
## The team’s name.
var team_name: String;
## The team’s display name.
var team_display_name: String;
## An ID that identifies the team.
var id: String;

static func from_json(d: Dictionary) -> TwitchTeam:
	var result = TwitchTeam.new();
	if d.has("users") && d["users"] != null:
		for value in d["users"]:
			result.users.append(Users.from_json(value));
	if d.has("background_image_url") && d["background_image_url"] != null:
		result.background_image_url = d["background_image_url"];
	if d.has("banner") && d["banner"] != null:
		result.banner = d["banner"];
	if d.has("created_at") && d["created_at"] != null:
		result.created_at = d["created_at"];
	if d.has("updated_at") && d["updated_at"] != null:
		result.updated_at = d["updated_at"];
	if d.has("info") && d["info"] != null:
		result.info = d["info"];
	if d.has("thumbnail_url") && d["thumbnail_url"] != null:
		result.thumbnail_url = d["thumbnail_url"];
	if d.has("team_name") && d["team_name"] != null:
		result.team_name = d["team_name"];
	if d.has("team_display_name") && d["team_display_name"] != null:
		result.team_display_name = d["team_display_name"];
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["users"] = [];
	if users != null:
		for value in users:
			d["users"].append(value.to_dict());
	d["background_image_url"] = background_image_url;
	d["banner"] = banner;
	d["created_at"] = created_at;
	d["updated_at"] = updated_at;
	d["info"] = info;
	d["thumbnail_url"] = thumbnail_url;
	d["team_name"] = team_name;
	d["team_display_name"] = team_display_name;
	d["id"] = id;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## 
class Users extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Users:
		var result = Users.new();
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

