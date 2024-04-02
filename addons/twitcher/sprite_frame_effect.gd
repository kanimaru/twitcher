extends RichTextEffect

## Shows spriteframes within richtext label.
## @usage use prepare_message before to load the image and prepare the message accordingly
class_name SpriteFrameEffect

const TRANSPARENT = preload("res://addons/twitcher/assets/transparent.tres");

static var regex: RegEx = RegEx.create_from_string("\\[sprite id=(?<id>.*?)\\](?<path>.*?)\\[/sprite\\]")

## Custom BB Code to use
var bbcode = "sprite";
## To track the emojis
## Key: Id as String ; Value: Emoji
var cache: Dictionary = {};
## To check if the message got already prepared
var ready: bool;

func prepare_message(message: String, parent: RichTextLabel) -> String:
	var found_matches = regex.search_all(message) as Array[RegExMatch];
	# We are changing the message content and want to preserve the match beginnings.
	# So we need to handle them in reverse
	found_matches.reverse();
	for m: RegExMatch in found_matches:
		var path = m.get_string("path");
		var id = m.get_string("id");
		var resource = ResourceLoader.load(path, "SpriteFrames") as SpriteFrames;
		var tex = resource.get_frame_texture("default", 0);
		var size = tex.get_size();
		var start = m.get_start(0);
		# Add an empty image to make the correct amount of space
		message = message.replace(path, "[img width=%s height=%s]%s[/img] " % [size.x, size.y, TRANSPARENT.resource_path]);
		var emoji = _create_emoji(resource);
		emoji.set_meta("size", size);
		cache[id] = emoji;
		parent.add_child(emoji);

	ready = true;
	return message;

func _create_emoji(resource: SpriteFrames):
	var node = AnimatedSprite2D.new();
	node.sprite_frames = resource;
	node.play();
	return node;

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if not ready: return true;
	var id = char_fx.env['id'];
	# unknown image just ignore
	if(!cache.has(id)): return true;
	char_fx.visible = false;

	if char_fx.relative_index != 0: return true;

	var node = cache[id];
	var image_size = node.get_meta("size");
	var right_bottom = char_fx.transform.get_origin();
	var image_height: float = image_size.y;
	var image_width: float = image_size.x;

	# The offset isn't correctly centering the images...
	# but we don't get the info about the line height to center it correctly
	var vertical_offset: float = right_bottom.y - image_height / 4.0;
	# Divided by 2 cause the origin of the image is centered
	var horizontal_offset: float = right_bottom.x + image_width / 2.0;
	cache[id].position = Vector2(horizontal_offset, vertical_offset);

	return true;
