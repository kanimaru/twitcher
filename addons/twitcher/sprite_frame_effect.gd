extends RichTextEffect

## Shows spriteframes within richtext label.[br]
## @usage use prepare_message before to load the image and prepare the message accordingly
class_name SpriteFrameEffect

const TRANSPARENT = preload("res://addons/twitcher/assets/transparent.tres")

static var regex: RegEx = RegEx.create_from_string("\\[sprite id=(?<id>.*?)\\](?<path>.*?)\\[/sprite\\]")

## Custom BB Code to use
var bbcode = "sprite"
## To track the emojis
## Key: Id as String  Value: Emoji
var cache: Dictionary = {}
## To check if the message got already prepared
var ready: bool
## Save theme for calculating line height
var parent_label: RichTextLabel
## If you don't want to have spaces between images (made for Foolbox <3)
var no_space: bool

func prepare_message(message: String, parent: RichTextLabel) -> String:
	parent_label = parent
	var found_matches = regex.search_all(message) as Array[RegExMatch]

	# We are changing the message content and want to preserve the match beginnings.
	# So we need to handle them in reverse
	found_matches.reverse()
	for m: RegExMatch in found_matches:
		var path = m.get_string("path")
		var id = m.get_string("id")
		var resource = ResourceLoader.load(path, "SpriteFrames") as SpriteFrames
		if resource == null: continue
		var tex = resource.get_frame_texture("default", 0)
		var size = tex.get_size()
		var start = m.get_start(0)
		# Add an empty image to make the correct amount of space
		message = message.replace(path, "[img width=%s height=%s]%s[/img]" % [size.x, size.y, TRANSPARENT.resource_path])
		var emoji = _create_emoji(resource)
		emoji.name = id
		emoji.set_meta("size", size)
		cache[id] = emoji
		parent.add_child(emoji)
	
	if no_space: message = message.replace("[/sprite] [sprite", "[/sprite][sprite")
	
	ready = true
	return message
	

func _create_emoji(resource: SpriteFrames):
	var node = AnimatedSprite2D.new()
	node.sprite_frames = resource
	node.centered = true
	node.play()
	return node


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if not ready: return true
	var id = char_fx.env['id']
	# unknown image just ignore
	if !cache.has(id): return true

	# Hide the original characters of the [sprite] tag content
	# (which should just be the placeholder [img] tag now)
	char_fx.visible = false

	# Only position the sprite once, using the first character's info
	if char_fx.relative_index != 0: return true

	var node: AnimatedSprite2D = cache[id]
	var image_size: Vector2 = node.get_meta("size") # Already stored in prepare_message
	
	# --- Get Font Metrics from RichTextLabel Theme ---
	var font: Font = char_fx.font if char_fx.font else parent_label.get_theme_font(&"normal_font")
	var font_size: int = parent_label.get_theme_font_size(&"normal_font_size")

	var font_ascent: float = 0.0
	var font_descent: float = 0.0 # Distance below baseline (positive value)

	if font:
		if font_size <= 0:
			font_size = parent_label.get_theme_default_font_size()
			if font_size <= 0: font_size = 16 # Absolute fallback

		# Get ascent and descent, scaled by the RichTextLabel's scale
		font_ascent = font.get_ascent(font_size) * parent_label.scale.y
		font_descent = font.get_descent(font_size) * parent_label.scale.y
	else:
		# Fallback estimation
		if font_size <= 0: font_size = 16
		var scaled_font_size = float(font_size) * parent_label.scale.y
		font_ascent = scaled_font_size * 0.8 # Estimate
		font_descent = scaled_font_size * 0.2 # Estimate
		printerr("SpriteFrameEffect: Could not determine font for ascent/descent calculation, using estimate.")

	# --- Calculate Position ---
	var baseline_origin: Vector2 = char_fx.transform.get_origin()

	# Horizontal center (remains the same)
	var center_x: float = baseline_origin.x + image_size.x / 2.0

	# Vertical position: Align sprite center with the vertical center of the font glyph box.
	# The top of the font box is at baseline_origin.y - font_ascent.
	# The bottom of the font box is at baseline_origin.y + font_descent.
	# The total height of the font box is font_ascent + font_descent.
	# The center relative to the baseline is baseline - ascent + (total_height / 2)
	# = baseline - ascent + (ascent + descent) / 2
	# = baseline - (ascent / 2) + (descent / 2)
	# = baseline - (ascent - descent) / 2.0
	var center_y: float = baseline_origin.y - (font_ascent - font_descent) / 2.0

	node.position = Vector2(center_x, center_y)
	return true
