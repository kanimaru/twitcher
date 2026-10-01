@tool
class_name TwitchLogSettings
extends RefCounted
## Where Twitcher's logs go, read from the project settings under
## [code]twitcher/logs/[/code]. [method from_project] registers every setting
## with its default, so they show up in the Project Settings.
##
## The per-context console settings ([code]twitcher/logs/<Context>[/code]) are
## separate and handled by [TwitchLoggerManager].

const FILE_LEVEL: String = "twitcher/logs/file/level"
const FILE_FORMAT: String = "twitcher/logs/file/format"
const FILE_DIRECTORY: String = "twitcher/logs/file/directory"
const FILE_MAX_LINES: String = "twitcher/logs/file/max_lines"
const FILE_MAX_FILES: String = "twitcher/logs/file/max_files"
const FILE_REDACT: String = "twitcher/logs/file/redact"
const STDOUT_LEVEL: String = "twitcher/logs/stdout/level"
const STDOUT_FORMAT: String = "twitcher/logs/stdout/format"
const CAPTURE_ENGINE: String = "twitcher/logs/capture_engine"

## Stdout level that turns on for headless and dedicated server builds only.
const AUTO: String = "auto"
const FORMAT_TEXT: String = "text"
const FORMAT_JSON_LINES: String = "jsonl"
const FORMAT_LOGFMT: String = "logfmt"

const DEFAULT_FILE_DIRECTORY: String = "user://logs"

## The levels Twitcher's loggers emit. The parsers accept trace and fatal too,
## but no Twitcher component logs at those levels, so they aren't offered.
const LEVEL_OPTIONS: Array[String] = ["off", "error", "warn", "info", "debug"]
const STDOUT_LEVEL_OPTIONS: Array[String] = ["auto", "off", "error", "warn", "info", "debug"]
const FORMAT_OPTIONS: Array[String] = ["text", "jsonl", "logfmt"]

## Threshold of the log file, see [enum TwitchLogLevel.Severity].
var file_level: int = TwitchLogLevel.Severity.INFO
var file_format: String = FORMAT_TEXT
var file_directory: String = DEFAULT_FILE_DIRECTORY
var file_max_lines: int = 1000
var file_max_files: int = 3
## Masks credentials in the file and on stdout.
var redact: bool = true
## Threshold of stdout, already resolved from [constant AUTO].
var stdout_level: int = TwitchLogLevel.OFF
var stdout_format: String = FORMAT_JSON_LINES
## Also writes engine errors and warnings ([method @GlobalScope.push_error]).
var capture_engine: bool = false
## [code]"editor"[/code], [code]"headless"[/code] or [code]"game"[/code].
var runtime: String = "game"


## Reads the settings, registering missing ones with their defaults.
static func from_project() -> TwitchLogSettings:
	var settings: TwitchLogSettings = TwitchLogSettings.new()
	settings.runtime = LogfamiResource.detect_runtime()
	settings.file_level = TwitchLogLevel.threshold_from_text(
			_select(FILE_LEVEL, "info", LEVEL_OPTIONS))
	settings.file_format = _select(FILE_FORMAT, FORMAT_TEXT, FORMAT_OPTIONS)
	settings.file_directory = str(TwitchProperty.new(FILE_DIRECTORY, DEFAULT_FILE_DIRECTORY)
			.as_dir().get_val())
	settings.file_max_lines = int(TwitchProperty.new(FILE_MAX_LINES, 1000).as_num().get_val())
	settings.file_max_files = int(TwitchProperty.new(FILE_MAX_FILES, 3).as_num().get_val())
	settings.redact = bool(TwitchProperty.new(FILE_REDACT, true).as_bool().get_val())
	settings.stdout_level = resolve_stdout_level(
			_select(STDOUT_LEVEL, AUTO, STDOUT_LEVEL_OPTIONS), settings.runtime)
	settings.stdout_format = _select(STDOUT_FORMAT, FORMAT_JSON_LINES, FORMAT_OPTIONS)
	settings.capture_engine = bool(TwitchProperty.new(CAPTURE_ENGINE, false).as_bool().get_val())
	return settings


## [constant AUTO] means info on headless and dedicated server builds and off
## everywhere else, the editor included.
static func resolve_stdout_level(text: String, current_runtime: String) -> int:
	if text.strip_edges().to_lower() != AUTO:
		return TwitchLogLevel.threshold_from_text(text)
	if current_runtime == LogfamiResource.RUNTIME_HEADLESS:
		return TwitchLogLevel.Severity.INFO
	return TwitchLogLevel.OFF


static func _select(key: String, default: String, options: Array[String]) -> String:
	var property: TwitchProperty = TwitchProperty.new(key, default)
	property.as_select(options, false)
	return str(property.get_val())


func is_editor() -> bool:
	return runtime == LogfamiResource.RUNTIME_EDITOR
