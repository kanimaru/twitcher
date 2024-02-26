@tool
extends TwitchImageTransformer

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
	return tex
