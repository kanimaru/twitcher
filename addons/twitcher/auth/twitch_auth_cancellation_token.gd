@tool
class_name TwitchAuthCancellationToken
extends RefCounted

signal cancelled()

var _cancelled: bool = false

func cancel() -> void:
	_cancelled = true
	cancelled.emit()

func is_cancelled() -> bool:
	return _cancelled

func wait_until_cancelled() -> void:
	if _cancelled:
		return

	await cancelled
