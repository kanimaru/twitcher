extends RichTextEffect

class_name SpriteFrameEffect

var node: AnimatedSprite2D;

func _init(frame: SpriteFrames, parent: Node):
	node = AnimatedSprite2D.new();
	node.sprite_frames = frame;
	node.play();
	parent.add_child(node);

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.offset = Vector2(12, 0);
	node.position = char_fx.transform.get_origin();
	print(node.position);
	return true;
