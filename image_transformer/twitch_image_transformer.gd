@tool
extends RefCounted

class_name TwitchImageTransformer

func is_supported() -> bool:
	return true

func is_supporting_animation():
	return false

func convert_image(path: String, buffer_in: PackedByteArray, output_path: String) -> SpriteFrames:
	if ResourceLoader.has_cached(output_path):
		return ResourceLoader.load(output_path);
	var img := Image.new();
	var err = img.load_png_from_buffer(buffer_in);
	var sprite_frames = SpriteFrames.new();
	var texture : Texture;
	if err == OK:
		texture = ImageTexture.new();
		texture.set_image(img);
		sprite_frames.take_over_path(output_path);
	else:
		texture = TwitchSetting.fallback_texture2d;

	sprite_frames.add_frame(&"default", texture);
	return sprite_frames;
