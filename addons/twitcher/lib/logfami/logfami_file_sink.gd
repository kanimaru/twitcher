@tool
class_name LogfamiFileSink
extends LogfamiSink
## Writes lines to a file that rotates by size and per session, keeping a
## bounded number of files. Safe to use from several threads.
## [codeblock]
## var config: LogfamiFileSinkConfig = LogfamiFileSinkConfig.new()
## config.base_name = "my_game"
## var sink: LogfamiFileSink = LogfamiFileSink.new(config)
## logfami.add_pipeline(LogfamiPipeline.new(LogfamiTextFormatter.new(), sink))
## print(sink.get_absolute_file_path())   # where users find the log
## [/codeblock]
## Every file starts with the formatter's session header. When the file can't
## be created or written, the sink reports it once with [method push_warning]
## and drops further lines instead of failing the game.

var config: LogfamiFileSinkConfig
var backend: LogfamiFileBackend
var rotation: LogfamiRotationPolicy

var _extension: String = "log"
var _header: PackedStringArray = []
var _lines_in_file: int = 0
var _lines_since_flush: int = 0
var _is_started: bool = false
var _is_open: bool = false
var _has_failed: bool = false
var _mutex: Mutex = Mutex.new()


func _init(sink_config: LogfamiFileSinkConfig = null,
		file_backend: LogfamiFileBackend = null) -> void:
	config = sink_config if sink_config != null else LogfamiFileSinkConfig.new()
	backend = file_backend if file_backend != null else LogfamiFsFileBackend.new()
	rotation = LogfamiRotationPolicy.new(config.max_lines, config.max_files)
	if config.extension != "":
		_extension = config.extension


func configure(formatter: LogfamiFormatter) -> void:
	if config.extension == "":
		_extension = formatter.file_extension()


func get_file_path() -> String:
	return config.directory.path_join("%s.%s" % [config.base_name, _extension])


## [method get_file_path] as an absolute path on the user's machine.
func get_absolute_file_path() -> String:
	return ProjectSettings.globalize_path(get_file_path())


## Every file of this sink that currently exists, newest first.
func get_existing_file_paths() -> PackedStringArray:
	var existing: PackedStringArray = []
	for path: String in rotation.all_paths(get_file_path()):
		if backend.exists(path):
			existing.append(path)
	return existing


## True once a failure stopped the sink from writing.
func has_failed() -> bool:
	return _has_failed


func start_session(header: PackedStringArray) -> void:
	_mutex.lock()
	_start(header)
	_mutex.unlock()


func write(line: String, record: LogfamiRecord) -> void:
	_mutex.lock()
	if not _is_started:
		_start(PackedStringArray())
	if _is_open:
		_write_record_line(line, record)
	_mutex.unlock()


func flush() -> void:
	_mutex.lock()
	if _is_open:
		backend.flush()
		_lines_since_flush = 0
	_mutex.unlock()


func close() -> void:
	_mutex.lock()
	if _is_open:
		backend.flush()
		backend.close()
		_is_open = false
	_mutex.unlock()


func _start(header: PackedStringArray) -> void:
	_is_started = true
	_header = header
	if not backend.make_dir(config.directory):
		_fail("can't create the log directory %s" % config.directory)
		return
	var path: String = get_file_path()
	if config.rotate_on_start and backend.exists(path):
		rotation.rotate(backend, path)
	_open(not config.rotate_on_start)


func _write_record_line(line: String, record: LogfamiRecord) -> void:
	if not backend.write_line(line):
		_fail("can't write to %s" % get_file_path())
		return
	_lines_in_file += 1
	_lines_since_flush += 1
	if _should_flush(record):
		backend.flush()
		_lines_since_flush = 0
	if rotation.should_rotate(_lines_in_file):
		backend.close()
		rotation.rotate(backend, get_file_path())
		_open(false)


func _open(append: bool) -> void:
	_lines_in_file = 0
	_lines_since_flush = 0
	if not backend.open_file(get_file_path(), append):
		_fail("can't open %s" % get_file_path())
		return
	_is_open = true
	for line: String in _header:
		backend.write_line(line)
	backend.flush()


func _should_flush(record: LogfamiRecord) -> bool:
	if config.flush_policy == LogfamiFileSinkConfig.FlushPolicy.EVERY_LINE:
		return true
	if record != null and record.severity_number >= config.flush_level:
		return true
	return _lines_since_flush >= config.flush_interval_lines


func _fail(reason: String) -> void:
	_is_open = false
	backend.close()
	if not _has_failed:
		_has_failed = true
		push_warning("Logfami file sink stopped: %s" % reason)
