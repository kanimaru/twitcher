extends EditorProperty

var _container: Node = GridContainer.new()

func _init():
	_container.columns = 2
	add_child(_container)
	set_bottom_editor(_container)


func _on_type_change(new_type: TwitchEventsubDefinition.Type) -> void:
	_create_conditions()


func _update_property() -> void:
	_create_conditions()


func _create_conditions() -> void:
	for node in _container.get_children():
		node.queue_free()

	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	if eventsub_config == null: return

	for condition_name: StringName in eventsub_config.definition.conditions:
		var condition_value = eventsub_config.condition.get_or_add(condition_name, "")
		var condition_title = Label.new()
		condition_title.text = condition_name.capitalize()
		var input = LineEdit.new()
		input.text_changed.connect(_on_change_text.bind(condition_name))
		input.text = condition_value
		input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_container.add_child(condition_title)
		_container.add_child(input)


func _on_change_text(new_text: String, condition_name: StringName) -> void:
	var eventsub_config: TwitchEventsubConfig = get_edited_object();
	eventsub_config.condition[condition_name] = new_text
	emit_changed(&"condition", eventsub_config.condition)
