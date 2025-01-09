extends EditorInspectorPlugin

const EventsubConfigProperty = preload("res://addons/twitcher/editor/inspector/eventsub_config_property.gd")

func _can_handle(object: Object) -> bool:
	return object is TwitchEventsubConfig


func _parse_property(object: Object, type: Variant.Type, name: String, \
		hint_type: PropertyHint, hint_string: String, usage_flags: int, \
		wide: bool) -> bool:

	if name == &"condition":
		add_property_editor("condition", EventsubConfigProperty.new(), true)
		return true
	if name == &"type":
		add_property_editor("type", ToDocs.new(), true, "Documentation")
	return false

class ToDocs extends EditorProperty:
	const EXT_LINK = preload("res://addons/twitcher/assets/ext-link.svg")

	var docs = Button.new()

	func _init() -> void:
		docs.text = "To dev.twitch.tv"
		docs.icon = EXT_LINK
		docs.pressed.connect(_on_to_docs)
		add_child(docs)
		add_focusable(docs)

	func _on_to_docs() -> void:
		var eventsub_config: TwitchEventsubConfig = get_edited_object()
		OS.shell_open(eventsub_config.definition.documentation_link)
