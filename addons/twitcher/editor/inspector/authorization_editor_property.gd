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
	var obj = get_edited_object()
	var twitch_auth: TwitchAuth
	if obj is TwitchService:
		var twitch_service: TwitchService = obj as TwitchService
		twitch_auth = twitch_service.auth
	elif obj is TwitchAuth:
		twitch_auth = obj as TwitchAuth
		
	if not twitch_auth.is_configured():
		printerr("%s is not configured correctly please fix the warnings." % obj.get_script())
	else:
		await twitch_auth.authorize()
