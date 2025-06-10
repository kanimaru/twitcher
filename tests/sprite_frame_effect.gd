extends Control

@export var sprite_frame: SpriteFrames

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	var effect: SpriteFrameEffect = SpriteFrameEffect.new()
	rich_text_label.install_effect(effect)
	rich_text_label.text = effect.prepare_message("This is a Animated Image: [sprite id='0']%s[/sprite]" % sprite_frame.resource_path, rich_text_label)