@tool
extends TwitchImageTransformer

class_name MagicImageTransformer

var converter: ImageMagickConverter
var imagemagic_path: String:
	set = update_imagemagic_path
var supported: bool


func is_supporting_animation() -> bool:
	return true


func update_imagemagic_path(path: String) -> void:
	imagemagic_path = path
	if imagemagic_path != "":
		var out = []
		var err = OS.execute(imagemagic_path, ['-version'], out)
		if err == OK:
			converter = ImageMagickConverter.new()
			converter.fallback_texture = fallback_texture
			converter.imagemagic_path = imagemagic_path
			_log.i("Imagemagic detected: %s use it to transform gif/webm" % [ imagemagic_path ])
			supported = true
			return
		_log.i("Imagemagic at '%s' path was not detected or has a wrong result code: %s \n %s" % [ imagemagic_path, err, "\n".join(out) ])
	supported = false


func is_supported() -> bool:
	return supported


func convert_image(path: String, buffer_in: PackedByteArray, output_path: String) -> SpriteFrames:
	return await converter.dump_and_convert(path, buffer_in, output_path)
