@tool
extends Node

class_name ImageMagickConverter

var log: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_IMAGE_LOADER);

## Current conversion in progress (key: path ; value: mutex)
var converting: Dictionary = {};
var fallback_sprite_frames: SpriteFrames;

static var delete_mutex: Mutex = Mutex.new()
static var folder_to_delete: Array[String] = []

## After that amount of files it starts to delete them
const DELETE_COUNT = 10

## Converts a packed byte array to a SpirteFrames and writes it out to the destination path
##
## The byte array must represent an animated gif, webp, or any imagemagick supported format
## it dumps it into a binary resource consisting of PNG frames.
##
## The resource is automatically added to the ResourceLoader cache as the input path value
func dump_and_convert(path: String, buffer_in: PackedByteArray = [], output = "%s.res" % path, parallel = false) -> SpriteFrames:
	var thread: Thread = Thread.new();
	var buffer: PackedByteArray = buffer_in.duplicate();
	var mutex: Mutex;
	if parallel:
		mutex = converting.get(path, Mutex.new());
		converting[path] = mutex;

	var err = thread.start(_do_work.bind(path, buffer, output, mutex));
	assert(err == OK, "could not start thread");

	# don't block the main thread while loading
	while not thread.is_started() or thread.is_alive():
		await Engine.get_main_loop().process_frame;

	var tex: SpriteFrames = thread.wait_to_finish();
	if parallel:
		mutex.unlock();
		converting.erase(path);

	if not output.is_empty():
		_save_converted_file(tex, output);
	return tex;

func _do_work(path: String, buffer: PackedByteArray, output: String, mutex: Mutex) -> SpriteFrames:
	if mutex != null:
		mutex.lock();
		# load from cache if another thread already completed converting this same resource
		if not output.is_empty() and ResourceLoader.has_cached(output):
			return ResourceLoader.load(output);

	# dump the buffer
	if FileAccess.file_exists(path):
		log.i("File found at %s, loading it instead of using the buffer." % path)
		buffer = FileAccess.get_file_as_bytes(path)
	else:
		DirAccess.make_dir_recursive_absolute(path.get_base_dir());
		var f = FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			log.e("Can't open file %s cause of %s" %[ path, FileAccess.get_open_error()])
		f.store_buffer(buffer)
		f.close()

	var frame_delays: Array[int] = _get_frame_delay(path);
	var folder_path: String = _create_temp_filename();
	if not _extract_images(path, folder_path):
		return _create_fallback_texture();
	var sprite_frames: SpriteFrames = _build_frames(folder_path, frame_delays);
	if not output.is_empty():
		sprite_frames.take_over_path(output);

	# delete the temp directory
	delete_mutex.lock()
	folder_to_delete.append(folder_path)
	delete_mutex.unlock()

	_cleanup()
	return sprite_frames

## Saves the texture to the output path
func _save_converted_file(tex: SpriteFrames, output: String):
	if not output.is_empty() and tex:
		ResourceSaver.save(tex, output, ResourceSaver.SaverFlags.FLAG_COMPRESS);
		tex.take_over_path(output);

func _create_unique_key(length: int = 8) -> String:
	var uniq = "";
	for i in range(length):
		uniq += "%d" % [randi() % 10];
	return uniq;

## Creates a folder to store the extracted images (needs the / at the end!)
func _create_temp_filename() -> String:
	var folder_path: String = "";
	var uniq = _create_unique_key();
	if Engine.is_editor_hint():
		folder_path = "res://.godot/magick_tmp/%s_%d/" % [uniq, Time.get_unix_time_from_system()];
	else:
		folder_path = "user://.magick_tmp/%s_%d/" % [uniq, Time.get_unix_time_from_system()];

	log.i("Create temp folder")
	DirAccess.make_dir_recursive_absolute(folder_path);
	return folder_path;

## Extracts all delays from the file in seconds
func _get_frame_delay(file: String) -> Array[int]:
	var out = [];
	var glob_path = ProjectSettings.globalize_path(file);
	OS.execute("magick", [ glob_path, "-format", "%T\\n", "info:" ], out);
	var frame_delays: Array[int] = [];
	for delay in out[0].split("\n"):
		# convert x100 to x1000(ms)
		frame_delays.append(delay.to_int() * 10);
	return frame_delays;

## Extracts all images from the file and saves them to folder path
func _extract_images(file: String, target_folder: String) -> bool:
	var out = [];
	var glob_file_path = ProjectSettings.globalize_path(file);
	var glob_extracted_file_path = ProjectSettings.globalize_path(target_folder + "%04d.png")
	var code = OS.execute("magick", [ "convert", "-coalesce", glob_file_path, glob_extracted_file_path ], out, true);
	if code != 0:
		log.e("unable to convert: %s" % "\n".join(out));
		return false;
	return true;

func _create_fallback_texture():
	var sprite_frames = SpriteFrames.new();
	sprite_frames.add_frame(&"default", TwitchSetting.fallback_texture2d);
	return sprite_frames;

func _build_frames(folder_path: String, frame_delays: Array[int]):
	log.i("Build Frames")
	var frames = DirAccess.get_files_at(folder_path);
	if len(frames) == 0:
		return _create_fallback_texture();

	var sprite_frames: SpriteFrames = SpriteFrames.new();
	for filepath in frames:
		var idx = filepath.substr(0, filepath.rfind(".")).to_int();
		var delay = frame_delays[idx] / 1000.0;
		var image = Image.new();
		var error = image.load(folder_path + filepath);
		if error != OK:
			return _create_fallback_texture();

		var frame = ImageTexture.create_from_image(image);
		sprite_frames.add_frame(&"default", frame, delay);
		sprite_frames.set_animation_speed(&"default", 1);
	return sprite_frames;

## Cleans after DELETE_COUNT amount of folder entries
func _cleanup(force: bool = false):
	if folder_to_delete.size() % DELETE_COUNT == 0 || force:
		delete_mutex.lock();
		for folder in folder_to_delete:
			var glob_folder = ProjectSettings.globalize_path(folder);
			OS.move_to_trash(glob_folder);
		folder_to_delete.clear();
		delete_mutex.unlock();
