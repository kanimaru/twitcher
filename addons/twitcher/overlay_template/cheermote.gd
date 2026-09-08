extends RigidBody2D

@export var sprite_frames: SpriteFrames:
	set = _update_sprite_frames
@export var size: float:
	set = _update_size


@onready var _circle_shape_2d: CircleShape2D = %CollisionShape2D.shape
@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D


func _update_sprite_frames(val: SpriteFrames) -> void:
	sprite_frames = val
	if not is_node_ready(): await ready
	_animated_sprite_2d.sprite_frames = val
	_animated_sprite_2d.play()


func _update_size(val: float) -> void:
	size = val
	if not is_node_ready(): await ready
	_circle_shape_2d.radius = val
	var sprite_frames: SpriteFrames = _animated_sprite_2d.sprite_frames
	var current_animation: StringName = _animated_sprite_2d.animation
	var texture: Texture = sprite_frames.get_frame_texture(current_animation, 0)

	if texture:
		var texture_width: float = texture.get_width()
		var target_diameter: float = val * 2.0
		var scale_factor: float = target_diameter / texture_width
		_animated_sprite_2d.scale = Vector2(scale_factor, scale_factor)
