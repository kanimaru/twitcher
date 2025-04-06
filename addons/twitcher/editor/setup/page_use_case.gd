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
@onready var scope_list_label: Label = %ScopeListLabel
@onready var scope_list: RichTextLabel = %ScopeList
@onready var to_documentation: Button = %ToDocumentation
@onready var scope_file_select: FileSelect = %ScopeFileSelect
@onready var scopes_container: HBoxContainer = %Scopes
@onready var other_scope_options: PanelContainer = %OtherScopeOptions
@onready var basic_scope_info: PanelContainer = %BasicScopeInfo
@onready var extended_scope_info: PanelContainer = %ExtendedScopeInfo
@onready var save: Button = %Save
@onready var scope_info: RichTextLabel = %ScopeInfo

var other_scope_property: TwitchScopeProperty = TwitchScopeProperty.new()
var scopes: TwitchOAuthScopes

signal use_case_changed(use_case: UseCase)


func _ready() -> void:
	scopes_container.hide()
	extended_scope_info.add_child(other_scope_property)
	scope_file_select.path = TwitchEditorSettings.get_scope_path()
	if scope_file_select.path == "":
		scope_file_select.path = "res://twitch_scopes.tres"
	
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	choose_button_group.pressed.connect(_on_choose)
	scope_file_select.file_selected.connect(_on_scope_file_selected)
	save.pressed.connect(_on_save_pressed)
	other_scope_property.scope_selected.connect(_on_scope_info)


func _on_scope_file_selected(path: String) -> void:
	TwitchEditorSettings.set_scope_path(path)
	

func _on_choose(button: BaseButton) -> void:
	other_scope_options.hide()
	extended_scope_info.hide()
	basic_scope_info.hide()
	match button:
		overlay:
			use_case_changed.emit(UseCase.Overlay)
			scopes = PRESET_OVERLAY_SCOPES
			TwitchEditorSettings.set_scope_path(PRESET_OVERLAY_SCOPES.resource_path)
			basic_scope_info.show()
		game:
			use_case_changed.emit(UseCase.Game)
			scopes = PRESET_GAME_SCOPES
			TwitchEditorSettings.set_scope_path(PRESET_GAME_SCOPES.resource_path)
			basic_scope_info.show()
		something_else:
			use_case_changed.emit(UseCase.Other)
			scopes = TwitchOAuthScopes.new()
			other_scope_property.set_object_and_property(scopes, "")
			extended_scope_info.show()
			other_scope_options.show()
	_show_selected_scopes()
	
func _on_scope_info(scope: TwitchScope.Definition) -> void:
	scope_info.text = _get_scope_info(scope)
	
	
func _on_save_pressed() -> void:
	var s_path = scope_file_select.path
	scopes.take_over_path(s_path)
	ResourceSaver.save(scopes, s_path)
	TwitchEditorSettings.set_scope_path(s_path)
	TwitchTweens.flash(save, Color.GREEN)
	
	
func _show_selected_scopes() -> void:
	scopes_container.show()
	
	var scope_description: String = ""
	for scope_name: StringName in scopes.used_scopes:
		var scope: TwitchScope.Definition = TwitchScope.SCOPE_MAP[scope_name]
		scope_description += _get_scope_info(scope)
	
	scope_list.text = scope_description
	
	
func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/scopes/")


func _get_scope_info(scope: TwitchScope.Definition) -> String:
	return "[b]%s[/b] - %s\n\n" % [scope.value, scope.description]
