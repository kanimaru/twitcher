@icon("res://addons/twitcher/assets/media-loader-icon.svg")
@tool
extends TwitchImageTransformer

## Native GIF parser written in GDScript and ported to Godot 4. Most of the time stable but there 
## are GIF's that may not work cause the file didn't follow the GIF specification.
class_name NativeImageTransformer


func is_supporting_animation() -> bool:
	return true


func convert_image(path: String, buffer_in: PackedByteArray, output_path: String) -> SpriteFrames:
	var reader = GifReader.new()
	var tex: SpriteFrames;
	if buffer_in.size() == 0:
		tex = reader.read(path);
	else:
		tex = reader.load_gif(buffer_in)
	_save_converted_file(tex, output_path);
	return tex


func _save_converted_file(tex: SpriteFrames, output: String):
	if not output.is_empty() and tex:
		ResourceSaver.save(tex, output, ResourceSaver.SaverFlags.FLAG_COMPRESS);
		tex.take_over_path(output);
