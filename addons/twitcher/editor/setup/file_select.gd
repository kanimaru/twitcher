@tool
extends Control

class_name FileSelect

@export var default_path: String
@export var path: String: set = update_filepath
@export var filters: PackedStringArray: set = update_filters

@onready var line_edit: LineEdit = %LineEdit
@onready var button: Button = %Button
@onready var file_dialog: FileDialog = %FileDialog

signal file_selected(path: String)


func _ready() -> void:
	var icon = EditorInterface.get_editor_theme().get_icon(&"FileBrowse", &"EditorIcons")
	button.icon = icon
	button.pressed.connect(_on_open_file_dialog)
	file_dialog.file_selected.connect(_on_file_selected)
	line_edit.text_changed.connect(_on_path_changed)
	update_filepath(path)
	update_filters(filters)
	
	
func update_filepath(new_path: String) -> void:
	if new_path == null || new_path == "":
		new_path = default_path
	path = new_path
	if is_inside_tree():
		line_edit.text = new_path
		file_dialog.current_path = new_path
	
	
func update_filters(new_filters: PackedStringArray) -> void:
	filters = new_filters
	if is_inside_tree():
		file_dialog.filters = new_filters
	
	
func _on_open_file_dialog() -> void:
	file_dialog.show()


func _on_path_changed(new_path: String) -> void:
	file_dialog.current_path = new_path
	path = new_path
	file_selected.emit(new_path)
	

func _on_file_selected(new_path: String) -> void:
	line_edit.text = new_path
	path = new_path
	file_selected.emit(new_path)
