extends EditorProperty

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

var _container: Node = GridContainer.new()

func _init():
	_container.columns = 2
	add_child(_container)
	set_bottom_editor(_container)


func _on_type_change(new_type: TwitchEventsubDefinition.Type) -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if eventsub_config != null:
		for meta in eventsub_config.get_meta_list():
			if meta.ends_with("_user"):
				eventsub_config.remove_meta(meta)
	_create_conditions()


func _update_property() -> void:
	_create_conditions()


func _create_conditions() -> void:
	for node in _container.get_children():
		node.queue_free()

	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if eventsub_config == null || eventsub_config.get_class() == &"EditorDebuggerRemoteObject": return

	for condition_name: StringName in eventsub_config.definition.conditions:
		var condition_value = eventsub_config.condition.get_or_add(condition_name, "")
		var condition_title = Label.new()
		condition_title.text = condition_name.capitalize()
		_container.add_child(condition_title)
		var editor_token = TwitchEditorSettings.editor_oauth_token
		if condition_name.to_lower().ends_with("user_id") && editor_token.is_token_valid():
			var user_converter = USER_CONVERTER.instantiate()
			user_converter.changed.connect(_on_changed_user.bind(condition_name))
			_container.add_child(user_converter)
			if eventsub_config.has_meta(condition_name + "_user"):
				var user = eventsub_config.get_meta(condition_name + "_user")
				user_converter.update_user(user)
			elif condition_value != "":
				user_converter.user_id = condition_value
				user_converter.reload()
		else:
			var input = LineEdit.new()
			input.text_submitted.connect(_on_change_text.bind(condition_name, input))
			input.focus_exited.connect(_on_change_text.bind("", condition_name, input))
			input.text = condition_value
			input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_container.add_child(input)


func _on_changed_user(user: TwitchUser, condition_name: StringName) -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if user == null:
		eventsub_config.condition[condition_name] = ""
		eventsub_config.remove_meta(condition_name + "_user")
		emit_changed(&"condition", eventsub_config.condition)
	else:
		eventsub_config.condition[condition_name] = user.id
		eventsub_config.set_meta(condition_name + "_user", user)
		emit_changed(&"condition", eventsub_config.condition)


func _on_change_text(new_text: String, condition_name: StringName, input: LineEdit) -> void:
	print("BLUB")
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	eventsub_config.condition[condition_name] = input.text
	#emit_changed(&"condition", eventsub_config.condition)
