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
	set = _update_user_login

var user_id: String:
	set = _update_user_id
	

signal changed(user: TwitchUser)


func _ready() -> void:
	_login.text_changed.connect(_on_login_changed)
	_login.text_submitted.connect(_on_text_submitted)
	_login.focus_exited.connect(_on_focus_exited)
	_id.text_changed.connect(_on_id_changed)
	_id.text_submitted.connect(_on_text_submitted)
	_id.focus_exited.connect(_on_focus_exited)
	_swap_view.pressed.connect(_on_swap_view)
	_load_current_user.call_deferred()
	search.pressed.connect(_on_changed)


func update_user(new_user: TwitchUser, notify: bool = false) -> void:
	if new_user:
		user_login = new_user.login
		user_id = new_user.id
	else:
		user_login = ""
		user_id = ""
	user = new_user
	if notify: changed.emit(new_user)
	

## Experimental tries to load user from api key
func _load_current_user() -> void:
	if _current_user == null:
		var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
		_current_user = await _load_user(users)
	
	if _current_user && not user_login && not user_id && TwitchEditorSettings.load_current_twitch_user:
		update_user(_current_user, true)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
		_swap_view.text = "ID"
	else:
		_login.visible = true
		_id.visible = false
		_swap_view.text = "Name"
	
	
func _update_user_login(val: String) -> void:
	user_login = val
	_login.text = val
	_login.caret_column = val.length()


func _update_user_id(val: String) -> void:
	user_id = val
	_id.text = val
	_id.caret_column = val.length()


func _on_id_changed(new_text: String) -> void:
	_login.text = ""
	TwitchTweens.loading(self, Color.AQUA)
	
	
func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	TwitchTweens.loading(self, Color.AQUA)


func reload() -> void:
	var new_user_login: String = _login.text
	var new_user_id: String = _id.text
	if new_user_id == "" && new_user_login == "":
		await TwitchTweens.flash(self, Color.GREEN)
		changed.emit(null)
		return
	
	if user != null && new_user_login == user.login && new_user_id == user.id: 
		return
	
	var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
		
	if new_user_login != "" && (not user || user.login != new_user_login):
		users.login = [ new_user_login ]
	elif new_user_id != "" && (not user || user.id != new_user_id):
		users.id = [ new_user_id ]
		
	var new_user: TwitchUser = await _load_user(users)
	if new_user != null: update_user(new_user, true)
	
	
func _load_user(users: TwitchGetUsers.Opt) -> TwitchUser:
	TwitchTweens.loading(self)
	if users.id != null || users.login != null:
		var new_user = await _get_user(users)
		if not new_user:
			await TwitchTweens.flash(self, Color.RED)
		else:
			await TwitchTweens.flash(self, Color.GREEN)
		return new_user
	return null


func _on_focus_exited() -> void:
	reload()
	
	
func _on_text_submitted(new_text: String) -> void:
	reload()


func _on_changed() -> void:
	reload()


func _get_user(get_user_opt: TwitchGetUsers.Opt) -> TwitchUser:
	var api: TwitchAPI = TwitchAPI.new()
	var _token: OAuthToken = token if token else TwitchEditorSettings.editor_oauth_token
	var _setting: OAuthSetting = setting if setting else TwitchEditorSettings.editor_oauth_setting
	api.token = _token
	api.oauth_setting = _setting
	add_child(api)
	var response: TwitchGetUsers.Response = await api.get_users(get_user_opt)
	var data: Array[TwitchUser] = response.data
	if data.is_empty():
		printerr("User %s%s was not found." % [ get_user_opt.login, get_user_opt.id ])
		return null
	remove_child(api)
	return data[0]
