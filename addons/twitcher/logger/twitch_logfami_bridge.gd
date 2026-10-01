@tool
class_name TwitchLogfamiBridge
extends RefCounted
## Sends Twitcher's log records to Logfami: a rolling log file, stdout on
## headless servers and, optionally, engine errors.
##
## Installed automatically on the first log call, configured through
## [TwitchLogSettings]. Players find the file via [method get_log_file_path]
## or [method open_log_folder]; in the editor the Project → Tools → Twitcher
## menu opens the folder.
##
## This class and [TwitchLogSettings] are the only places where Twitcher knows
## Logfami; Logfami itself knows nothing about Twitcher.

const FILE_BASE_NAME: String = "twitcher"
const EDITOR_FILE_BASE_NAME: String = "twitcher_editor"
const TWITCHER_VERSION_ATTRIBUTE: String = "twitcher.version"

## Whether Twitcher installs the bridge on its own on the first log call.
## Set it to false before then, e.g. in the [code]_init[/code] of an autoload,
## when an application brings its own handler. Creating loggers doesn't count
## as logging, so static loggers in your scripts don't get in the way.
## [method uninstall] turns it off as well.
static var auto_install: bool = true
static var _instance: TwitchLogfamiBridge

var settings: TwitchLogSettings
var logfami: Logfami
var file_sink: LogfamiFileSink
var stdout_sink: LogfamiStdoutSink
var engine_capture: LogfamiEngineCapture

var _handler: Callable
var _is_console_suppressed: bool = false


## Installs the bridge from the project settings unless [member auto_install]
## is off or a bridge is already installed. Called by [TwitchLoggerManager].
static func install_once() -> void:
	if not auto_install or _instance != null:
		return
	install(TwitchLogSettings.from_project())


## Replaces the installed bridge with one built from [param log_settings].
static func install(log_settings: TwitchLogSettings, file_backend: LogfamiFileBackend = null,
		log_clock: LogfamiClock = null) -> TwitchLogfamiBridge:
	uninstall()
	var bridge: TwitchLogfamiBridge = TwitchLogfamiBridge.new(
			log_settings, file_backend, log_clock)
	bridge._connect()
	_instance = bridge
	return bridge


## Detaches the installed bridge, closes its files and turns
## [member auto_install] off, so the next log call doesn't bring it back.
static func uninstall() -> void:
	auto_install = false
	if _instance == null:
		return
	_instance._disconnect()
	_instance = null


static func get_instance() -> TwitchLogfamiBridge:
	return _instance


## Absolute path of the current log file, empty when file logging is off.
static func get_log_file_path() -> String:
	if _instance == null or _instance.file_sink == null:
		return ""
	return _instance.file_sink.get_absolute_file_path()


## Absolute path of the log folder, from the settings even when no bridge is
## installed.
static func get_log_folder_path() -> String:
	if _instance != null and _instance.file_sink != null:
		return _instance.file_sink.get_absolute_file_path().get_base_dir()
	var directory: String = str(ProjectSettings.get_setting(
			TwitchLogSettings.FILE_DIRECTORY, TwitchLogSettings.DEFAULT_FILE_DIRECTORY))
	return ProjectSettings.globalize_path(directory)


## Opens the log folder in the system's file manager.
static func open_log_folder() -> void:
	var folder: String = get_log_folder_path()
	DirAccess.make_dir_recursive_absolute(folder)
	OS.shell_show_in_file_manager(folder)


func _init(log_settings: TwitchLogSettings, file_backend: LogfamiFileBackend = null,
		log_clock: LogfamiClock = null) -> void:
	settings = log_settings
	var resource: LogfamiResource = LogfamiResource.detect().with_attribute(
			TWITCHER_VERSION_ATTRIBUTE, Twitcher.VERSION)
	logfami = Logfami.new(resource, log_clock)
	if settings.file_level < TwitchLogLevel.OFF:
		_add_file_pipeline(file_backend)
	if settings.stdout_level < TwitchLogLevel.OFF:
		_add_stdout_pipeline()
	if settings.capture_engine:
		engine_capture = LogfamiEngineCapture.new(logfami)


func _add_file_pipeline(file_backend: LogfamiFileBackend) -> void:
	var config: LogfamiFileSinkConfig = LogfamiFileSinkConfig.new()
	config.directory = settings.file_directory
	config.base_name = EDITOR_FILE_BASE_NAME if settings.is_editor() else FILE_BASE_NAME
	config.max_lines = settings.file_max_lines
	config.max_files = settings.file_max_files
	file_sink = LogfamiFileSink.new(config, file_backend)
	var formatter: LogfamiFormatter = _create_formatter(settings.file_format, false)
	_add_pipeline(LogfamiPipeline.new(formatter, file_sink, settings.file_level))


func _add_stdout_pipeline() -> void:
	stdout_sink = LogfamiStdoutSink.new()
	var formatter: LogfamiFormatter = _create_formatter(settings.stdout_format, true)
	_add_pipeline(LogfamiPipeline.new(formatter, stdout_sink, settings.stdout_level))


## Collectors reading stdout of many processes need the resource on every
## line; files carry it in their header.
func _create_formatter(format_name: String, is_stream: bool) -> LogfamiFormatter:
	match format_name:
		TwitchLogSettings.FORMAT_JSON_LINES:
			var json: LogfamiJsonLinesFormatter = LogfamiJsonLinesFormatter.new()
			json.include_resource = is_stream
			return json
		TwitchLogSettings.FORMAT_LOGFMT:
			return LogfamiLogfmtFormatter.new()
		_:
			return LogfamiTextFormatter.new()


func _add_pipeline(pipeline: LogfamiPipeline) -> void:
	if settings.redact:
		pipeline.add_processor(LogfamiRedactor.with_defaults())
	logfami.add_pipeline(pipeline)


func _connect() -> void:
	if logfami.get_pipelines().is_empty():
		return
	_handler = logfami.as_handler()
	TwitchLoggerManager.add_handler(_handler, logfami.min_level())
	if stdout_sink != null:
		# The console prints to stdout as well; every line would show twice.
		var console: TwitchConsoleLogHandler = TwitchLoggerManager.get_console_handler()
		_is_console_suppressed = TwitchLoggerManager.has_handler(console.handle)
		TwitchLoggerManager.remove_handler(console.handle)
	if engine_capture != null:
		engine_capture.install()


func _disconnect() -> void:
	if _handler.is_valid():
		TwitchLoggerManager.remove_handler(_handler)
	if _is_console_suppressed:
		TwitchLoggerManager.install_console_handler()
	if engine_capture != null:
		engine_capture.uninstall()
	logfami.close()
