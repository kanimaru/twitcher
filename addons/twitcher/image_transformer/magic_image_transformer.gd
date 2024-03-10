@tool
extends TwitchImageTransformer

class_name MagicImageTransformer

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_IMAGE_LOADER);

var converter: ImageMagickConverter;

func is_supporting_animation():
	return true;

func is_supported() -> bool:
	if TwitchSetting.imagemagic_path != "":
		var out = []
		var err = OS.execute(TwitchSetting.imagemagic_path, ['-version'], out);
		if err == OK:
			converter = ImageMagickConverter.new();
			log.i("Imagemagic detected: %s use it to transform gif/webm" % [ TwitchSetting.imagemagic_path ]);
			return true;
		log.i("Imagemagic was not detected or has a wrong result code: " % [ "\n".join(out) ]);
	return false;

func convert_image(path: String, buffer_in: PackedByteArray, output_path: String) -> SpriteFrames:
	return await converter.dump_and_convert(path, buffer_in, output_path);
