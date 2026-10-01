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
## The config is read once at construction; changing it afterwards has no
## effect on the sink. Every file starts with the formatter's session header.
## When the file can't be created or written, the sink reports it once with
## [method push_warning] and drops further lines instead of failing the game.

## The config this sink was built from, for inspection.
var config: LogfamiFileSinkConfig
var backend: LogfamiFileBackend
var rotation: LogfamiRotationPolicy

var _directory: String
var _base_name: String
var _extension: String = "log"
var _rotate_on_start: bool
var _flush_policy: LogfamiFileSinkConfig.FlushPolicy
var _flush_level: int
var _flush_interval_lines: int
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
	_directory = config.directory
	_base_name = config.base_name
	if config.extension != "":
		_extension = config.extension
	_rotate_on_start = config.rotate_on_start
	_flush_policy = config.flush_policy
	_flush_level = config.flush_level
	_flush_interval_lines = config.flush_interval_lines


func configure(formatter: LogfamiFormatter) -> void:
	if config.extension == "":
		_extension = formatter.file_extension()


func get_file_path() -> String:
	return _directory.path_join("%s.%s" % [_base_name, _extension])


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
	if not backend.make_dir(_directory):
		_fail("can't create the log directory %s" % _directory)
		return
	var path: String = get_file_path()
	if _rotate_on_start and backend.exists(path):
		rotation.rotate(backend, path)
	_open(not _rotate_on_start)


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


## Opens the current file. When appending, the lines already in it count
## towards the rotation limit.
func _open(append: bool) -> void:
	var path: String = get_file_path()
	_lines_in_file = backend.line_count(path) if append else 0
	_lines_since_flush = 0
	if not backend.open_file(path, append):
		_fail("can't open %s" % path)
		return
	_is_open = true
	for line: String in _header:
		backend.write_line(line)
	backend.flush()


func _should_flush(record: LogfamiRecord) -> bool:
	if _flush_policy == LogfamiFileSinkConfig.FlushPolicy.EVERY_LINE:
		return true
	if record != null and record.severity_number >= _flush_level:
		return true
	return _lines_since_flush >= _flush_interval_lines


## Reports the failure once. The warning goes through the engine, so a
## [LogfamiEngineCapture] feeding the same Logfami sees it again; the sink is
## closed by then, so that record is dropped here rather than looping.
func _fail(reason: String) -> void:
	_is_open = false
	backend.close()
	if not _has_failed:
		_has_failed = true
		push_warning("Logfami file sink stopped: %s" % reason)
