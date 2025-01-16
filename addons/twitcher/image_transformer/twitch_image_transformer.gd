@tool
extends RefCounted

class_name TwitchImageTransformer

static var _log: TwitchLogger = TwitchLogger.new("TwitchImageTransformer")

var fallback_texture: Texture2D = preload("res://addons/twitcher/assets/fallback_texture.tres")


func is_supporting_animation() -> bool:
	return false


func is_supported() -> bool:
	return true


func convert_image(path: String, buffer_in: PackedByteArray, output_path: String) -> SpriteFrames:
	if ResourceLoader.has_cached(output_path):
		return ResourceLoader.load(output_path)
	var img := Image.new()
	var err = img.load_png_from_buffer(buffer_in)
	var sprite_frames = SpriteFrames.new()
	var texture : Texture
	if err == OK:
		texture = ImageTexture.new()
		texture.set_image(img)
		sprite_frames.add_frame(&"default", texture)
		ResourceSaver.save(sprite_frames, output_path, ResourceSaver.SaverFlags.FLAG_COMPRESS)
		sprite_frames.take_over_path(path)
	else:
		sprite_frames.add_frame(&"default", fallback_texture)
		_log.e("Can't load %s use fallback" % output_path)

	return sprite_frames
