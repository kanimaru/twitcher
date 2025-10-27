@tool
extends Control

class_name FileSelect

@export var default_path: String
@export var path: String: set = _update_filepath
@export var filters: PackedStringArray: set = _update_filters
@export var placeholder: String
@export var pick_folder: bool
@onready var line_edit: LineEdit = %LineEdit
@onready var button: Button = %Button
@onready var file_dialog: FileDialog = %FileDialog

signal file_selected(path: String)


func _ready() -> void:
	if Engine.is_editor_hint():
		var icon: Texture2D = EditorInterface.get_editor_theme().get_icon(&"FileBrowse", &"EditorIcons")
		button.icon = icon
	button.pressed.connect(_on_open_file_dialog)
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.dir_selected.connect(_on_file_selected)
	if pick_folder: file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	line_edit.text_submitted.connect(_on_path_changed)
	line_edit.placeholder_text = placeholder
	
	_update_filepath(path)
	_update_filters(filters)
	
	file_dialog.current_path = path
	
	
func _update_filepath(new_path: String) -> void:
	if new_path == null || new_path == "":
		new_path = default_path
	path = new_path
	if not is_node_ready(): return
	line_edit.text = path
	
	
func _update_filters(new_filters: PackedStringArray) -> void:
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
