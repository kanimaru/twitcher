@tool
extends Button

@onready var _image: TextureRect = %Image
@onready var _title: Label = %Title

@export var texture: Texture2D:
	set = _update_texture
	
@export var title: String


func _ready() -> void:
	_update_texture(texture)
	_title.text = title


func _pressed() -> void:
	OS.shell_open("https://dashboard.twitch.tv/viewer-rewards/channel-points/rewards")


func _update_texture(val: Texture2D) -> void:
	texture = val
	if not is_node_ready(): return
	if val:
		_image.texture = val
	else:
		_image.texture = GradientTexture1D.new()
