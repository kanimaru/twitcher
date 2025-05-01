extends Node

@export var show_elements: Array[Control] = []


func _ready() -> void:
	for element: Control in show_elements:
		element.hide()
		
	for child in get_children():
		if child.has_signal(&"focus_entered"):
			child.connect(&"focus_entered", _on_focus_entered)
		if child.has_signal(&"focus_exited"):
			child.connect(&"focus_exited", _on_focus_exited)
	
	
func _on_focus_entered() -> void:
	for element: Node in show_elements:
		element.show()
		
	
func _on_focus_exited() -> void:
	for element: Node in show_elements:
		element.hide()
