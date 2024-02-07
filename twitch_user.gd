extends RefCounted

class_name TwitchUser

const ROLE_ADMIN: StringName = &"admin"
const ROLE_GLOBAL_MOD: StringName = &"global_mod"
const ROLE_STAFF: StringName = &"staff"
const ROLE_USER: StringName = &""

const BC_TYPE_AFFILIATE: StringName = &"affiliate"
const BC_TYPE_PARTNER: StringName = &"partner"
const BC_TYPE_NORMAL: StringName = &""

var id: String;
var login: String;
var display_name: String;
var type: String;
var broadcaster_type: String;
var description: String;
var profile_image_url: String;
var offline_image_url: String;
var created_at: String;

static func load_from_json(json: Dictionary) -> TwitchUser:
	var user := TwitchUser.new();
	user.id = json['id']
	user.login = json['login']
	user.display_name = json['display_name']
	user.type = json['type']
	user.broadcaster_type = json['broadcaster_type']
	user.description = json['description']
	user.profile_image_url = json['profile_image_url']
	user.offline_image_url = json['offline_image_url']
	user.created_at = json['created_at']
	return user;
