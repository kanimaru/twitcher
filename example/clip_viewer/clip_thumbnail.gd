extends Control

class_name ClipThumbnail

@export var texture: ImageTexture:
	set = _update_texture

@export var title: String:
	set = _update_title
	
@onready var _thumbnail: TextureRect = %Thumbnail
@onready var _title: Label = %Title

signal clicked

func _ready() -> void:
	_update_texture(texture)
	_update_title(title)
	gui_input.connect(_on_gui_input)

func _update_title(val: String) -> void:
	title = val
	if not is_node_ready(): return
	_title.text = val


func _update_texture(val: ImageTexture) -> void:
	texture = val
	if not is_node_ready(): return
	_thumbnail.texture = val


func _on_gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		clicked.emit()
