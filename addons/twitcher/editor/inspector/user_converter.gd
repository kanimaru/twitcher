@tool
extends HBoxContainer

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

@onready var _login: LineEdit = %Login
@onready var _id: LineEdit = %Id
@onready var _swap_view: Button = %SwapView
@onready var _debounce: Timer = %Debounce

@export var user: TwitchUser

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
	_login.text_changed.connect(_on_login_changed)
	_id.text_changed.connect(_on_id_changed)
	_swap_view.pressed.connect(_on_swap_view)
	_debounce.timeout.connect(_on_changed)


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
	loading()
	_debounce.start()
	
	
func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	loading()
	_debounce.start()


func reload() -> void:
	loading()
	_on_changed()


func loading() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.YELLOW, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func flash(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", color, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func update_user(user: TwitchUser) -> void:
	user_login = user.login
	user_id = user.id


func _on_changed() -> void:
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
		if user != null:
			user_login = user.login
			user_id = user.id
		
		changed.emit(user)


func _get_user(get_user_opt: TwitchGetUsers.Opt) -> TwitchUser:
	var api: TwitchAPI = TwitchAPI.new()
	api.token = TwitchEditorSettings.editor_token
	api.oauth_setting = TwitchEditorSettings.oauth_setting
	add_child(api)
	var response: TwitchGetUsers.Response = await api.get_users(get_user_opt)
	var data: Array[TwitchUser] = response.data
	if data.is_empty():
		flash(Color.RED)
		printerr("User %s%s was not found." % [ get_user_opt.login, get_user_opt.id ])
		return null
	remove_child(api)
	await flash(Color.GREEN)
	return data[0]
	
