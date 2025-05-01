@tool
extends MarginContainer

enum UseCase {
	Overlay, Game, Other
}

const PRESET_GAME_SCOPES = preload("res://addons/twitcher/auth/preset_game_scopes.tres")
const PRESET_OVERLAY_SCOPES = preload("res://addons/twitcher/auth/preset_overlay_scopes.tres")
const TwitchScopeProperty = preload("res://addons/twitcher/editor/inspector/twitch_scope_property.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@export var choose_button_group: ButtonGroup

@onready var overlay: CheckBox = %Overlay
@onready var game: CheckBox = %Game
@onready var something_else: CheckBox = %SomethingElse
@onready var scope_list: RichTextLabel = %ScopeList
@onready var to_documentation: Button = %ToDocumentation
@onready var scope_file_select: FileSelect = %ScopeFileSelect
@onready var scopes_container: HBoxContainer = %Scopes
@onready var advanced_edit: CheckButton = %AdvancedEdit
@onready var other_scope_options: PanelContainer = %OtherScopeOptions
@onready var extended_scope_info: PanelContainer = %ExtendedScopeInfo
@onready var save: Button = %Save

var other_scope_property: TwitchScopeProperty = TwitchScopeProperty.new()
var scopes: TwitchOAuthScopes: set = update_scopes
var has_changes: bool:
	set(val): 
		has_changes = val
		changed.emit()
		save.text = save.text.trim_suffix(" (unsaved changes)")
		if has_changes: save.text += " (unsaved changes)"

signal changed
signal use_case_changed(use_case: UseCase)


func _ready() -> void:	
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	choose_button_group.pressed.connect(_on_choose)
	scope_file_select.file_selected.connect(_on_scope_file_selected)
	save.pressed.connect(_on_save_pressed)
	other_scope_property.scope_selected.connect(_on_scope_info)
	advanced_edit.toggled.connect(_on_toggle_advanced_edit)
	
	scopes_container.hide()
	extended_scope_info.hide()
	extended_scope_info.add_child(other_scope_property)
	
	# Reset radio buttons cause it's a tool script and the radio button stay and won't throw another signal otherwise
	game.set_pressed_no_signal(false)
	overlay.set_pressed_no_signal(false)
	something_else.set_pressed_no_signal(false)
	
	scope_file_select.path = TwitchEditorSettings.get_scope_path()
	match TwitchEditorSettings.project_preset: 
		TwitchEditorSettings.PRESET_GAME:
			game.button_pressed = true
		TwitchEditorSettings.PRESET_OVERLAY:
			overlay.button_pressed = true
		TwitchEditorSettings.PRESET_OTHER:
			something_else.button_pressed = true
			
	# Needs to be resetted cause the radio reset will change the has_changges to true
	has_changes = false

func _on_scope_file_selected(path: String) -> void:
	has_changes = true
	if FileAccess.file_exists(path):
		var resource = load(path)
		if resource is OAuthScopes: scopes = resource
		else: OS.alert("The selected scope is not a scope file, it will be overwritten!")
	
	
func _on_toggle_advanced_edit(toggled_on: bool) -> void:
	extended_scope_info.visible = toggled_on
	

func _on_choose(button: BaseButton) -> void:
	match button:
		overlay:
			use_case_changed.emit(UseCase.Overlay)
			scopes = PRESET_OVERLAY_SCOPES.duplicate(true)
			advanced_edit.button_pressed = false
			TwitchEditorSettings.project_preset = TwitchEditorSettings.PRESET_OVERLAY
		game:
			use_case_changed.emit(UseCase.Game)
			scopes = PRESET_GAME_SCOPES.duplicate(true)
			advanced_edit.button_pressed = false
			TwitchEditorSettings.project_preset = TwitchEditorSettings.PRESET_GAME
		something_else:
			use_case_changed.emit(UseCase.Other)
			scopes = TwitchOAuthScopes.new()
			advanced_edit.button_pressed = true
			TwitchEditorSettings.project_preset = TwitchEditorSettings.PRESET_OTHER
			
	_show_selected_scopes()
	has_changes = true
	
func _on_scope_info(scope: TwitchScope.Definition) -> void:
	_show_selected_scopes()
	
	
func _on_save_pressed() -> void:
	var s_path = scope_file_select.path
	scopes.take_over_path(s_path)
	ResourceSaver.save(scopes, s_path)
	TwitchEditorSettings.set_scope_path(s_path)
	TwitchTweens.flash(save, Color.GREEN)
	has_changes = false
	
	
func _show_selected_scopes() -> void:
	scopes_container.show()
	
	if scopes.used_scopes.is_empty():
		scope_list.text = "[i]No scopes selected yet[/i]"
		return
	
	var scope_description: String = ""
	for scope_name: StringName in scopes.used_scopes:
		var scope: TwitchScope.Definition = TwitchScope.SCOPE_MAP[scope_name]
		scope_description += "[b]%s[/b] - %s\n\n" % [scope.value, scope.description]
	
	scope_list.text = scope_description
	
	
func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/scopes/")


func update_scopes(val: TwitchOAuthScopes) -> void:
	scopes = val
	other_scope_property.set_object_and_property(scopes, "")
	other_scope_property.update_property()
	_show_selected_scopes()
