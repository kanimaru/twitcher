@tool
class_name LogfamiFileSinkConfig
extends Resource
## Settings of a [LogfamiFileSink]. A [Resource], so it can live in a
## [code].tres[/code] file and be edited in the inspector.

enum FlushPolicy {
	## Flush after every line. Nothing is lost on a crash; costs a write per line.
	EVERY_LINE,
	## Flush on [member flush_level] and above, and every
	## [member flush_interval_lines] lines.
	ON_LEVEL_OR_INTERVAL,
}

## Usually under [code]user://[/code]; the inspector's folder picker only
## offers [code]res://[/code] paths, so this is a plain text field.
@export var directory: String = "user://logs"
@export var base_name: String = "app"
## Without the dot. Empty uses the formatter's extension.
@export var extension: String = ""
## Record lines per file before it rotates; 0 never rotates on size.
@export var max_lines: int = 1000
## Files kept in total, the current one included.
@export var max_files: int = 3
## Moves the previous session's file aside on start, so every session begins a
## fresh file. Off appends to the existing file instead.
@export var rotate_on_start: bool = true
@export var flush_policy: FlushPolicy = FlushPolicy.EVERY_LINE
## Lowest severity that flushes right away with
## [constant FlushPolicy.ON_LEVEL_OR_INTERVAL].
@export var flush_level: int = LogfamiLevel.Severity.WARN
@export var flush_interval_lines: int = 20
