@tool
class_name TwitchLogDebuggerPlugin
extends EditorDebuggerPlugin
## Hooks [TwitchLogDebuggerLink] into the editor's debugger, so the records of a
## game started from the editor reach the log panel. Only the editor can create
## it; the logic lives in the link.

var link: TwitchLogDebuggerLink


func _init(debugger_link: TwitchLogDebuggerLink = null) -> void:
	link = debugger_link if debugger_link != null else TwitchLogDebuggerLink.new()


func _has_capture(prefix: String) -> bool:
	return prefix == TwitchLogDebuggerRelay.CAPTURE


func _capture(message: String, data: Array, _session_id: int) -> bool:
	return link.capture(message, data)


func _setup_session(session_id: int) -> void:
	var session: EditorDebuggerSession = get_session(session_id)
	link.add_session(session_id, session)
	session.started.connect(link.on_session_started)
