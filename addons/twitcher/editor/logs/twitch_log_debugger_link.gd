@tool
class_name TwitchLogDebuggerLink
extends RefCounted
## Editor side of the link to a running game, see [TwitchLogDebuggerRelay].
##
## Collects the records the game sends into [member game_buffer] and passes the
## context modes picked in the panel on to the game. It holds the logic of
## [TwitchLogDebuggerPlugin], which can only exist inside the editor, so it works
## with anything that offers [code]is_active()[/code] and
## [code]send_message(message, data)[/code] like an [EditorDebuggerSession].

## Where the game's records land.
var game_buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
## Empties [member game_buffer] whenever a game starts.
var clear_on_start: bool = true

var _sessions: Dictionary[int, Object] = {}


## Handles a message of the game. Returns true when it belongs to the link.
func capture(message: String, data: Array) -> bool:
	if message != TwitchLogDebuggerRelay.RECORD_MESSAGE:
		return false
	if not data.is_empty() and data[0] is Dictionary:
		game_buffer.add(LogfamiRecord.from_dict(data[0]))
	return true


func add_session(session_id: int, session: Object) -> void:
	_sessions[session_id] = session


## A game started: its log starts fresh when [member clear_on_start] is set.
func on_session_started() -> void:
	if clear_on_start:
		game_buffer.clear()


## True while at least one game is connected.
func is_game_running() -> bool:
	return _active_sessions().size() > 0


## Tells every running game to switch [param context] to [param mode]. Returns
## the number of games reached.
func send_mode(context: String, mode: String) -> int:
	var reached: int = 0
	for session: Object in _active_sessions():
		session.send_message(TwitchLogDebuggerRelay.SET_MODE_MESSAGE, [context, mode])
		reached += 1
	return reached


func _active_sessions() -> Array[Object]:
	var active: Array[Object] = []
	for session: Object in _sessions.values():
		if is_instance_valid(session) and session.is_active():
			active.append(session)
	return active
