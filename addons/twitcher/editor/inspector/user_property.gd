@tool
extends EditorProperty
class_name UserProperty

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const UserConverter = preload("res://addons/twitcher/editor/inspector/user_converter.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

var _converter: UserConverter
var _user_property_name: StringName


func _init(user_property_name: StringName):
	_user_property_name = user_property_name

	_converter = USER_CONVERTER.instantiate()
	_converter.changed.connect(_on_changed)
	
	add_child(_converter)


func _update_property() -> void:
	var user: TwitchUser = get_edited_object()[get_edited_property()]
	if user == null:
		_converter.user_id = ""
		_converter.user_login = ""
	else:
		_converter.user_id = user.id
		_converter.user_login = user.login


func _on_changed(new_user_login: String, new_user_id: String) -> void:
	if new_user_id == "" && new_user_login == "":
		emit_changed(get_edited_property(), null, &"", true)
		return
	var current_user: TwitchUser = get_edited_object()[get_edited_property()]
	var has_changed: bool = false
	var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
	
	if new_user_login != "" && (current_user == null || current_user.login != new_user_login):
		users.login = [ new_user_login ]
	elif new_user_id != "" && (current_user == null || current_user.id != new_user_id):
		users.id = [ new_user_id ]
	
	if users.id != null || users.login != null:
		var user = await _get_user(users)
		emit_changed(get_edited_property(), user, &"", true)
		_update_property()


func _on_user_login_changed(new_user_login: String) -> void:
	if new_user_login == "":
		emit_changed(get_edited_property(), null, &"", true)
	
	var current_user_login: TwitchUser = get_edited_object()[get_edited_property()]
	if current_user_login == null || new_user_login != current_user_login.login:
		var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
		users.login = [ new_user_login ]
		var user = await _get_user(users)
		emit_changed(get_edited_property(), user, &"", true)
	_update_property()


func _get_user(get_user_opt: TwitchGetUsers.Opt) -> TwitchUser:
	var api: TwitchAPI = TwitchAPI.new()
	api.token = TwitchEditorSettings.editor_token
	api.oauth_setting = TwitchEditorSettings.oauth_setting
	add_child(api)
	var response: TwitchGetUsers.Response = await api.get_users(get_user_opt)
	var data: Array[TwitchUser] = response.data
	if data.is_empty():
		_converter.flash(Color.RED)
		printerr("User %s%s was not found." % [ get_user_opt.login, get_user_opt.id ])
		return null
	remove_child(api)
	_converter.flash(Color.GREEN)
	return data[0]
	
