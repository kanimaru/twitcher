extends Control

var draggging: bool


func _ready() -> void:
	var viewport = get_viewport()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		draggging = event.pressed

	if not draggging: return
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event
		position += Vector2(mouse_event.relative)
