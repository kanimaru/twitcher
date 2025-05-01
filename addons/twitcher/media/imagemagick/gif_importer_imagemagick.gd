@tool
extends EditorImportPlugin

class_name GifImporterImagemagick

enum Presets { DEFAULT }

func _get_importer_name() -> String:
	return "kani_dev.imagemagick"

func _get_visible_name() -> String:
	return "SpriteFrames (ImageMagick)"

func _get_recognized_extensions() -> PackedStringArray:
	return ["gif", "webp"]

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "SpriteFrames"

func _get_priority() -> float:
	return 100.0

func _get_preset_count() -> int:
	return Presets.size()

func _get_preset_name(preset_index: int) -> String:
	return "Default"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []

func _get_import_order() -> int:
	return 0

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var dumper = ImageMagickConverter.new()

	var tex = await dumper.dump_and_convert(source_file, [], "")
	if tex:
		return ResourceSaver.save(
			tex,
			"%s.%s" % [save_path, _get_save_extension()],
			ResourceSaver.SaverFlags.FLAG_COMPRESS
		)
	push_error("failed to import %s" % source_file)
	return OK;
