extends EditorProperty

var _container: Node
var _authorize: Button


func _init() -> void:
	_container = VBoxContainer.new()

	_authorize = Button.new()
	_authorize.text = "Authorize Editor"
	_authorize.pressed.connect(_on_authorize)
	
	_container.add_child(_authorize)
	add_focusable(_authorize)

	add_child(_container)
	set_bottom_editor(_container)


func _on_authorize() -> void:
	var twitch_auth: TwitchAuth = get_edited_object()	
	if not twitch_auth.is_configured():
		printerr("%s is not configured correctly please fix the warnings." % twitch_auth.name)
	else:
		await twitch_auth.authorize()
