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


signal changed(user: String, id: String)


func _ready() -> void:
	_login.text_changed.connect(_on_login_changed)
	_id.text_changed.connect(_on_id_changed)
	_swap_view.pressed.connect(_on_swap_view)
	_debounce.timeout.connect(_on_changed)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
		_swap_view.text = "Name"
	else:
		_login.visible = true
		_id.visible = false
		_swap_view.text = "ID"


func _on_changed() -> void:
	changed.emit(_login.text, _id.text)
	

func _on_id_changed(new_text: String) -> void:
	_login.text = ""
	loading()
	_debounce.start()
	
	
func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	loading()
	_debounce.start()


func loading() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.YELLOW, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func flash(color: Color) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", color, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
