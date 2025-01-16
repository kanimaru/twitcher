@tool
extends HBoxContainer

@onready var _login: LineEdit = %Login
@onready var _id: LineEdit = %Id
@onready var _swap_view: Button = %SwapView
@onready var _debounce: Timer = %Debounce

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

signal user_login_changed(user: String)


func _ready() -> void:
	_login.text_changed.connect(_on_login_changed)
	_swap_view.pressed.connect(_on_swap_view)
	_debounce.timeout.connect(_on_debounce_ended)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
	else:
		_login.visible = true
		_id.visible = false


func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	_debounce.start()


func _on_debounce_ended() -> void:
	user_login_changed.emit(user_login)
