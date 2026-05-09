@tool
extends Window

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")
const SectionReward = preload("uid://byv7ndmkuf3pf")

@onready var authorize: Button = %Authorize
@onready var twitch_auth: TwitchAuth = %TwitchAuth

@onready var section_reward: SectionReward = %SectionReward
@onready var authorization: PanelContainer = %Authorization

func _ready() -> void:
	if not TwitchEditorSettings.is_valid():
		OS.alert("Editor Authorization is not valid. Check Project/Tools/Twitcher/Setup!")
		queue_free()
		return

	authorize.pressed.connect(_on_authorize)

	twitch_auth.oauth_setting = TwitchEditorSettings.editor_oauth_setting.duplicate()
	twitch_auth.oauth_setting.authorization_flow = OAuth.AuthorizationFlow.AUTHORIZATION_CODE_FLOW
	section_reward.token = twitch_auth.token
	section_reward.setting = twitch_auth.oauth_setting

	if twitch_auth.is_authenticated:
		_set_authenticated()
	else:
		_set_unauthenticated()


func _on_authorize() -> void:
	if await twitch_auth.authorize():
		_set_authenticated()
		TwitchTweens.flash(authorize, Color.GREEN)
	else:
		TwitchTweens.flash(authorize, Color.RED)


func _set_authenticated() -> void:
	authorization.hide()
	section_reward.show()


func _set_unauthenticated() -> void:
	authorization.show()
	section_reward.hide()
