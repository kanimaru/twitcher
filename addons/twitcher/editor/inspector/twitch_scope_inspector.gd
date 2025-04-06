extends EditorInspectorPlugin

const TwitchScopeProperty = preload("res://addons/twitcher/editor/inspector/twitch_scope_property.gd")

func _can_handle(object: Object) -> bool:
	return object is TwitchOAuthScopes


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "used_scopes":
		add_property_editor("used_scopes", TwitchScopeProperty.new(), true);
		return false;
	return false
