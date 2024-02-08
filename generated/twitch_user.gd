@tool
extends RefCounted

class_name TwitchUser

## An ID that identifies the user.
var id: String;
## The user's login name.
var login: String;
## The user's display name.
var display_name: String;
## The type of user. Possible values are:      * admin — Twitch administrator * global\_mod * staff — Twitch staff * "" — Normal user
var type: String;
## The type of broadcaster. Possible values are:      * affiliate — An [affiliate broadcaster](https://help.twitch.tv/s/article/joining-the-affiliate-program target=) * partner — A [partner broadcaster](https://help.twitch.tv/s/article/partner-program-overview) * "" — A normal broadcaster
var broadcaster_type: String;
## The user's description of their channel.
var description: String;
## A URL to the user's profile image.
var profile_image_url: String;
## A URL to the user's offline image.
var offline_image_url: String;
## The number of times the user's channel has been viewed.      **NOTE**: This field has been deprecated (see [Get Users API endpoint – "view\_count" deprecation](https://discuss.dev.twitch.tv/t/get-users-api-endpoint-view-count-deprecation/37777)). Any data in this field is not valid and should not be used.
var view_count: int;
## The user's verified email address. The object includes this field only if the user access token includes the **user:read:email** scope.      If the request contains more than one user, only the user associated with the access token that provided consent will include an email address — the email address for all other users will be empty.
var email: String;
## The UTC date and time that the user's account was created. The timestamp is in RFC3339 format.
var created_at: Variant;

static func from_json(d: Dictionary) -> TwitchUser:
	var result = TwitchUser.new();
	result.id = d["id"];
	result.login = d["login"];
	result.display_name = d["display_name"];
	result.type = d["type"];
	result.broadcaster_type = d["broadcaster_type"];
	result.description = d["description"];
	result.profile_image_url = d["profile_image_url"];
	result.offline_image_url = d["offline_image_url"];
	result.view_count = d["view_count"];
	result.email = d["email"];
	result.created_at = d["created_at"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["login"] = login;
	d["display_name"] = display_name;
	d["type"] = type;
	d["broadcaster_type"] = broadcaster_type;
	d["description"] = description;
	d["profile_image_url"] = profile_image_url;
	d["offline_image_url"] = offline_image_url;
	d["view_count"] = view_count;
	d["email"] = email;
	d["created_at"] = created_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

