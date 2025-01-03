@tool
extends HBoxContainer

@export var rest: TwitchRestAPI:
	set(val):
		rest = val
		_update_rest()

@onready var _login: LineEdit = %Login
@onready var _id: LineEdit = %Id
@onready var _swap_view: Button = %SwapView
@onready var _debounce: Timer = %Debounce

var _user: TwitchUser
var user_login: String:
	set(val):
		user_login = val
		_login.text = val
		_login.caret_column = val.length()
	get(): return _user.login

var user_id: String:
	set(val):
		user_id = val
		_id.text = val
		_id.caret_column = val.length()
	get(): return _user.id

## User was loaded after changing id or login
signal user_loaded(user: TwitchUser)

func _ready() -> void:
	_update_rest()
	_login.text_changed.connect(_on_login_changed)
	_id.text_changed.connect(_on_id_changed)
	_swap_view.pressed.connect(_on_swap_view)
	_debounce.timeout.connect(_on_debounce_ended)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
	else:
		_login.visible = true
		_id.visible = false


func _update_rest() -> void:
	if rest != null:
		_login.editable = true
		_id.editable = true
		_swap_view.disabled = false
	else:
		_login.editable = false
		_id.editable = false
		_swap_view.disabled = true


func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	_debounce.start()


func _on_id_changed(new_text: String) -> void:
	_login.text = ""
	_debounce.start()


func _on_debounce_ended() -> void:
	if _login.text != "":
		await load_user(_login.text, "")
	elif _id.text != "":
		await load_user("", _id.text)


func load_user(login: String, id: String) -> TwitchUser:
	_user = null

	if rest == null: return
	var user_response: TwitchGetUsersResponse
	if login != "":
		user_response = await rest.get_users([], [login])
	else:
		user_response = await rest.get_users([id], [])

	if user_response.data.is_empty():
		print_debug("No twitch user found with %s" % [login if login != "" else id])
		return

	_user = user_response.data[0]
	user_login = _user.login
	user_id = _user.id
	user_loaded.emit(_user)
	return _user
