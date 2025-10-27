@tool
extends EditorInspectorPlugin

const TWITCH_REWARD_INFO: PackedScene = preload("res://addons/twitcher/editor/inspector/twitch_reward_info.tscn")
const TwitchAuthorizeEditor = preload("res://addons/twitcher/editor/inspector/twitch_authorize_editor.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")


func _can_handle(object: Object) -> bool:
	return object is TwitchReward
	
	
func _parse_category(object: Object, category: String) -> void:
	if category == "twitch_reward.gd":
		if TwitchEditorSettings.is_valid():
			var info: Node = TWITCH_REWARD_INFO.instantiate()
			info.twitch_reward = object
			add_custom_control(info)
		#else:
			# Actually I wanted to show the TwitchAuthorizeEditor in case the editor is not authorized yet.
			# But in reality the TwitchUser Inspector is doing that for the broadcaster user of the 
			# TwitchReward already and steals the job from this one :D
			
			#var authorize_editor = TwitchAuthorizeEditor.new(name)
			#authorize_editor.authorized.connect(_on_authorized.bind(object), CONNECT_DEFERRED)
			#add_custom_control(authorize_editor)


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, \
	hint_string: String, usage_flags: int, wide: bool) -> bool:
	# remove the current editor for all properties
		
	# If editor is authorized (true) remove all properties / otherwise show default insepctor (false)
	return TwitchEditorSettings.is_valid()
	

func _on_authorized(object: Object) -> void:
	EditorInterface.get_inspector().edit(null)
	EditorInterface.get_inspector().edit(object)
