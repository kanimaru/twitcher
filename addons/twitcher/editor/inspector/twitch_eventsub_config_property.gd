extends EditorProperty

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

var _container: Node = GridContainer.new()
var _current_type: TwitchEventsubDefinition.Type

func _init():
	_container.columns = 2
	add_child(_container)
	set_bottom_editor(_container)


func _cleanup_unused_meta() -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if eventsub_config == null: return
	
	var conditions: Array[StringName] = eventsub_config.definition.conditions
	var unused_conditions: Array[StringName] = eventsub_config.get_meta_list() \
		.filter(func(cond: StringName): 
			var is_user_property = cond.ends_with("_user")
			var condition_not_found = conditions.find(cond.trim_suffix("_user")) == -1
			return is_user_property && condition_not_found)
		
	for unused_condition: StringName in unused_conditions:
		eventsub_config.remove_meta(unused_condition)


func _update_property() -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	
	_cleanup_unused_meta()
	_clean_conditions()
	_create_conditions()


func _clean_conditions() -> void:
	for node in _container.get_children():
		node.queue_free()
	
	
func _create_conditions() -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if eventsub_config == null || eventsub_config.get_class() == &"EditorDebuggerRemoteObject": return

	for condition_name: StringName in eventsub_config.definition.conditions:
		var condition_value = eventsub_config.condition.get_or_add(condition_name, "")
		_create_condition_title(condition_name)

		var editor_token = TwitchEditorSettings.editor_oauth_token
		if condition_name.to_lower().ends_with("user_id") && editor_token.is_token_valid():
			_create_editor_supported_input(eventsub_config, condition_name, condition_value)
		else:
			_create_manual_input(condition_name, condition_value)
		
		
func _create_condition_title(condition_name: String) -> void:
	var condition_title = Label.new()
	condition_title.text = condition_name.capitalize()
	_container.add_child(condition_title)
	

func _create_editor_supported_input(eventsub_config: TwitchEventsubConfig, \
		condition_name: String, \
		condition_value: String) -> void:
	var user_converter = USER_CONVERTER.instantiate()
	user_converter.changed.connect(_on_changed_user.bind(eventsub_config, condition_name))
	_container.add_child(user_converter)
	
	if eventsub_config.has_meta(condition_name + "_user"):
		var user = eventsub_config.get_meta(condition_name + "_user")
		user_converter.update_user(user)
	elif condition_value != "":
		user_converter.user_id = condition_value
		user_converter.reload()


func _create_manual_input(condition_name: String, condition_value: String) -> void:
	var input = LineEdit.new()
	input.text_submitted.connect(_on_change_text.bind(condition_name, input))
	input.focus_exited.connect(_on_change_text.bind("", condition_name, input))
	input.text = condition_value
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_container.add_child(input)


func _on_changed_user(user: TwitchUser, \
		eventsub_config: TwitchEventsubConfig, \
		condition_name: StringName) -> void:
	var conditions: Dictionary = eventsub_config.condition.duplicate()
	if user == null:
		conditions[condition_name] = ""
		eventsub_config.remove_meta(condition_name + "_user")
	else:
		conditions[condition_name] = user.id
		eventsub_config.set_meta(condition_name + "_user", user)
	eventsub_config.condition = conditions
	emit_changed(&"condition", eventsub_config.condition)

func _on_change_text(new_text: String, condition_name: StringName, input: LineEdit) -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	eventsub_config.condition[condition_name] = input.text
	#emit_changed(&"condition", eventsub_config.condition)
