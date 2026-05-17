@tool
extends Button

signal changed(changes: bool)

@export var has_changes: bool:
	set(val):
		has_changes = val
		changed.emit.call_deferred(val)
		text = text.trim_suffix(" (unsaved changes)")
		if has_changes: text += " (unsaved changes)"
