@tool
extends HBoxContainer

class_name UserConverter

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var _login: LineEdit = %Login
@onready var _id: LineEdit = %Id
@onready var _swap_view: Button = %SwapView
@onready var search: Button = %Search

@export var user: TwitchUser
@export var token: OAuthToken
@export var setting: OAuthSetting

static var _current_user: TwitchUser

var user_login: String:
	set(val):
		user_login = val
		_login.text = val
		_login.caret_column = val.length()
	get(): return _login.text

var user_id: String:
	set(val):
		user_id = val
		_id.text = val
		_id.caret_column = val.length()
	get(): return _id.text


signal changed(user: TwitchUser)


func _ready() -> void:
	if token == null: token = TwitchEditorSettings.editor_oauth_token
	if setting == null: setting = TwitchEditorSettings.editor_oauth_setting
	
	_login.text_changed.connect(_on_login_changed)
	_login.text_submitted.connect(_on_text_submitted)
	_id.text_changed.connect(_on_id_changed)
	_id.text_submitted.connect(_on_text_submitted)
	_swap_view.pressed.connect(_on_swap_view)
	_load_current_user()
	search.pressed.connect(_on_changed)


## Experimental tries to load user from api key
func _load_current_user() -> void:
	if _current_user == null:
		var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
		_current_user = await _get_user(users)
		
	if _current_user != null:
		user_login = _current_user.login
		user_id = _current_user.id
		changed.emit(_current_user)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
		_swap_view.text = "ID"
	else:
		_login.visible = true
		_id.visible = false
		_swap_view.text = "Name"
	

func _on_id_changed(new_text: String) -> void:
	_login.text = ""
	TwitchTweens.loading(self, Color.AQUA)
	
	
func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	TwitchTweens.loading(self, Color.AQUA)


func reload() -> void:
	TwitchTweens.loading(self)
	var new_user_login: String = _login.text
	var new_user_id: String = _id.text
	if new_user_id == "" && new_user_login == "":
		changed.emit(null)
		return
	
	var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
	
	if new_user_login != "" && (user == null || user.login != new_user_login):
		users.login = [ new_user_login ]
	elif new_user_id != "" && (user == null || user.id != new_user_id):
		users.id = [ new_user_id ]
	
	if users.id != null || users.login != null:
		user = await _get_user(users)
		if user == null:
			await TwitchTweens.flash(self, Color.RED)
		else:
			await TwitchTweens.flash(self, Color.GREEN)
			user_login = user.login
			user_id = user.id
			changed.emit(user)


func update_user(user: TwitchUser) -> void:
	user_login = user.login
	user_id = user.id


func _on_text_submitted(new_text: String) -> void:
	reload()


func _on_changed() -> void:
	reload()


func _get_user(get_user_opt: TwitchGetUsers.Opt) -> TwitchUser:
	var api: TwitchAPI = TwitchAPI.new()
	api.token = token
	api.oauth_setting = setting
	add_child(api)
	var response: TwitchGetUsers.Response = await api.get_users(get_user_opt)
	var data: Array[TwitchUser] = response.data
	if data.is_empty():
		printerr("User %s%s was not found." % [ get_user_opt.login, get_user_opt.id ])
		return null
	remove_child(api)
	return data[0]