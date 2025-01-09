extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is TwitchEventsub || object is TwitchService


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "scopes":
		add_property_editor("scope_validation", ScopeValidation.new(), true, "Scope Validation")
	return false


class ScopeValidation extends EditorProperty:
	const WARNING_LABEL_SETTINGS = preload("res://addons/twitcher/assets/warning_label_settings.tres")
	const INFO_LABEL_SETTINGS = preload("res://addons/twitcher/assets/info_label_settings.tres")
	var _warning_label: Label = Label.new();
	var _apply_scopes: Button = Button.new();
	var _needed_scopes: Dictionary = {}
	var container: Control = VBoxContainer.new()


	func _init():
		_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_warning_label.text = "Press validate to check if scopes maybe are missing."

		var validate_button = Button.new();
		validate_button.text = "Validate";
		validate_button.tooltip_text = "Checks the scopes of the subscriptions " \
						  + " if they match the defined scopes in the scope " \
						  + " property";
		validate_button.pressed.connect(_on_validate_scopes);

		_apply_scopes.text = "Apply Scopes";
		_apply_scopes.tooltip_text = "Apply Scopes to the scope resource in " \
			+ " this TwitchEventsub. It maybe not needed depending on the " \
			+ " Subscription. Please check the documentation if there is a logical " \
			+ " condition and apply the scopes accordingly.";
		_apply_scopes.pressed.connect(_on_apply_scopes);

		add_child(validate_button)
		container.add_child(_warning_label)
		add_child(container)
		set_bottom_editor(container)


	func _on_apply_scopes() -> void:
		var scopes = get_edited_object().scopes;
		var scopes_to_add: Array[StringName] = [];
		for scope in _needed_scopes.values():
			scopes_to_add.append(scope);
		scopes.add_scopes(scopes_to_add);
		_clear_warning();


	func _on_validate_scopes() -> void:
		var scopes = get_edited_object().scopes;
		var subscriptions = get_edited_object().get_subscriptions();

		_needed_scopes.clear()
		for subscription: TwitchEventsubConfig in subscriptions:
			if subscription == null: continue
			for scope in subscription.definition.scopes:
				_needed_scopes[scope] = scope

		for scope in scopes.used_scopes:
			_needed_scopes.erase(scope)

		if !_needed_scopes.is_empty():
			if _apply_scopes.get_parent() == null: container.add_child(_apply_scopes)
			_warning_label.label_settings = WARNING_LABEL_SETTINGS
			var needed_scopes = ", ".join(_needed_scopes.values())
			_warning_label.text = "You may miss scopes please check documentation if you need to add: %s" % needed_scopes;
		else:
			_clear_warning()


	func _clear_warning() -> void:
		_warning_label.text = "Scopes seems to be OK for this EventSub."
		_warning_label.label_settings = INFO_LABEL_SETTINGS
		if _apply_scopes.get_parent() != null:
			container.remove_child(_apply_scopes)
