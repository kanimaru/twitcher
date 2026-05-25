@tool
extends Node

const SectionDefaultUserView = preload("uid://bkvsg1os5pj6a")
const SectionAuthorizationView = preload("uid://c601gt6x3ydpq")
const SectionDefaultResourceView = preload("uid://b28mmhk5a83yy")
const OVERLAY_TEMPLATE = preload("uid://6121fuoll1yk")
const TwitchEditorNodeUtils = preload("uid://cwvdheqhq5yrl")
const TwitchEditorSettings = preload("uid://kqcukq2xqnuf")

@onready var to_documentation: Button = %ToDocumentation

@onready var authorization_view: SectionAuthorizationView = %OverlayAuthorizationView
@onready var default_user_view: SectionDefaultUserView = %DefaultUserView
@onready var default_ressource_view: SectionDefaultResourceView = %DefaultRessourceView

@onready var default_resource: FoldableContainer = %DefaultResource
@onready var default_user: FoldableContainer = %DefaultUser

signal changed

var has_changes: bool:
	get():
		return authorization_view.has_changes \
			or default_user_view.has_changes \
			or default_ressource_view.has_changes


func _ready() -> void:
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	authorization_view.authorized.connect(_on_authorized)
	default_ressource_view.token = TwitchEditorSettings.game_oauth_token if TwitchEditorSettings.game_oauth_token else OAuthToken.new()
	default_ressource_view.setting = TwitchEditorSettings.editor_oauth_setting.duplicate()
	_set_unauthorized()


func save() -> bool:
	if not authorization_view.save():
		return false
	if not default_user_view.save():
		return false
	if not default_ressource_view.save():
		return false
	return true


func bootstrap() -> void:
	TwitchEditorNodeUtils.new_scene()
	var root_node = OVERLAY_TEMPLATE.instantiate()
	root_node.scene_file_path = ""
	root_node.name = "Overlay"
	var twitch_service: TwitchService = root_node.get_node(^"TwitchService")
	twitch_service.token = TwitchEditorSettings.game_oauth_token
	twitch_service.oauth_setting = TwitchEditorSettings.game_oauth_setting
	var eventsub: TwitchEventsub = root_node.get_node(^"TwitchService/EventSub")
	# Replace all configured user with the default user
	if not TwitchEditorSettings.load_current_twitch_user:
		eventsub._subscriptions.clear()
		eventsub._action_stack.clear()
		push_warning("Because of no default user. You have to configure the eventsub yourself!")
	else:
		for subscription: TwitchEventsubConfig in eventsub._subscriptions:
			for key: String in subscription.condition:
				var value: Variant = subscription.condition[key]
				if key.ends_with("user_id"):
					subscription.condition[key] = TwitchEditorSettings.default_user.id
					subscription.set_meta(key + "_user", TwitchEditorSettings.default_user)

	EditorInterface.add_root_node(root_node)


func _set_authorized() -> void:
	default_user.show()
	default_resource.show()


func _set_unauthorized() -> void:
	default_resource.hide()
	default_user.hide()


func _on_authorized() -> void:
	_set_authorized()


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
