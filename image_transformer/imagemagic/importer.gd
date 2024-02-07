@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name():
	return "kani_dev.imagemagick"

func _get_visible_name():
	return "SpriteFrames (ImageMagick)"

func _get_recognized_extensions():
	return ["gif", "webp"]

func _get_save_extension():
	return "res"

func _get_resource_type():
	return "SpriteFrames"

func _get_priority():
	return 100.0

func _get_preset_count():
	return Presets.size()

func _get_preset_name(preset):
	return "Default"

func _get_import_options(path, preset):
	return []

func _get_import_order():
	return 0

func _get_option_visibility(path, option, options):
	return true

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	print("Importer loaded")
	var dumper = ImageMagickConverter.new()
	var tex = await dumper.dump_and_convert(source_file, [], "")
	if tex:
		return ResourceSaver.save(
			tex,
			"%s.%s" % [save_path, _get_save_extension()],
			ResourceSaver.SaverFlags.FLAG_COMPRESS
		)
	push_error("failed to import %s" % source_file)

