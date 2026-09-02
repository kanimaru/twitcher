extends EditorProperty

## Button that opens the Twitch documentation of the currently selected subscription.
## Works for every object that provides the [TwitchEventsubDefinition] via `definition`.
## (See [TwitchEventsubConfig] and [TwitchEventListener])

const EXT_LINK = preload("res://addons/twitcher/assets/ext-link.svg")

var docs = Button.new()


func _init() -> void:
	docs.text = "To dev.twitch.tv"
	docs.icon = EXT_LINK
	docs.pressed.connect(_on_to_docs)
	add_child(docs)
	add_focusable(docs)


func _on_to_docs() -> void:
	var target: Object = get_edited_object()
	if target == null || target.get_class() == &"EditorDebuggerRemoteObject": return
	OS.shell_open(target.definition.documentation_link)
