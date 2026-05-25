extends Control

@onready var _profile: TextureRect = %Profile
@onready var _username: Label = %Username
@onready var _text: Label = %Text
@onready var _shoot_twitch_command: TwitchCommand = %ShootTwitchCommand

@export var text: String:
	set = _update_text
@export var user_name: String:
	set = _update_user_name
@export var image: Texture:
	set = _update_image

var _shot: bool

func _enter_tree() -> void:
	_tween_in()


func _ready() -> void:
	_shoot_twitch_command.command_received.connect(_on_shoot_command_received)


func queue_free() -> void:
	if _shot:
		await _shot_out()
	else:
		await _tween_out()
	super.queue_free()


func _tween_in() -> void:
	var current_position: Vector2 = global_position
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, ^"modulate", Color.WHITE, 1) \
		.from(Color.TRANSPARENT)
	tween.tween_property(self, ^"global_position", current_position, 1) \
		.from(global_position + Vector2.LEFT * 10)


func _tween_out() -> void:
	var current_position: Vector2 = global_position
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(self, ^"modulate", Color.TRANSPARENT, 1)
	tween.tween_property(self, ^"global_position", global_position + Vector2.RIGHT * 10, 1)
	await tween.finished


func _shot_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^"rotation_degrees", 110, 1)
	tween.tween_property(self, ^"rotation_degrees", 60, 1)
	tween.tween_property(self, ^"rotation_degrees", 80, 1)
	tween.tween_property(self, ^"rotation_degrees", 70, 1)
	tween.tween_property(self, ^"rotation_degrees", 80, 1)
	tween.set_parallel()
	tween.tween_property(self, ^"modulate", Color.TRANSPARENT, .3)
	tween.tween_property(self, ^"global_position", global_position + Vector2.DOWN * 100, .5)
	await tween.finished


func _update_user_name(val: String) -> void:
	user_name = val
	if not is_node_ready(): await ready
	_username.text = val



func _update_image(val: Texture) -> void:
	image = val
	if not is_node_ready(): await ready
	_profile.texture = val


func _update_text(val: String) -> void:
	text = val
	if not is_node_ready(): await ready
	_text.text = val


func _on_shoot_command_received(from_username: String, info: TwitchCommandInfo, args: PackedStringArray) -> void:
	_shot = true
