# Derived from https://github.com/jegor377/godot-gdgifexporter

@tool
extends EditorImportPlugin

class_name GifImporterNative

func _get_importer_name():
	return "gif.animated.texture.plugin"

func _get_priority():
	return 0;

func _get_visible_name():
	return "Sprite Frames (Native)"

func _get_recognized_extensions():
	return ["gif"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "SpriteFrames"

func _get_import_order():
	return 0;

func _get_preset_count():
	return 1

func _get_preset_name(i):
	return "Default"

func _get_import_options(path: String, preset_index: int):
	return []

func _import(source_file, save_path, options, platform_variants, gen_files):
	var reader = GifReader.new()
	var tex = reader.read(source_file)
	if tex == null:
		return FAILED
	var filename = save_path + "." + _get_save_extension()
	return ResourceSaver.save(tex, filename)
