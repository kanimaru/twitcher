# Derived from https://github.com/jegor377/godot-gdgifexporter

@tool
extends EditorImportPlugin

class_name GifImporterNative

enum Presets { DEFAULT }

func _get_importer_name() -> String:
	return "gif.animated.texture.plugin"

func _get_visible_name() -> String:
	return "Sprite Frames (Native)"

func _get_recognized_extensions() -> PackedStringArray:
	return ["gif"]

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "SpriteFrames"

func _get_priority() -> float:
	return 90.0;

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
	var reader = GifReader.new()
	var tex = reader.read(source_file)
	if tex == null:
		return FAILED
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(
		tex,
		"%s.%s" % [save_path, _get_save_extension()],
		ResourceSaver.SaverFlags.FLAG_COMPRESS
	)
