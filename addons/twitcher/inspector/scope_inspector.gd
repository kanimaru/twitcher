extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is OAuthScopes


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name == "used_scopes":
		add_property_editor("used_scopes", ScopeProperty.new(), true);
		return true;
	return false


class ScopeProperty extends EditorProperty:
	const TITLE_SETTING := preload("res://addons/twitcher/assets/title_label_settings.tres")
	## Key: StringName | Value: CheckBox
	var _scope_checkboxes: Dictionary
	var grid := GridContainer.new();

	func _init() -> void:
		grid.columns = 1;
		var grouped_scopes = TwitchScope.get_grouped_scopes();
		for category: String in grouped_scopes:
			var title_category = Label.new();
			title_category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
			title_category.text = category.capitalize();
			title_category.label_settings = TITLE_SETTING;
			grid.add_child(title_category);
			grid.add_child(Control.new());

			for scope: TwitchScope.Definition in grouped_scopes[category]:
				var checkbox = CheckBox.new();
				checkbox.text = scope.value;
				#var scopes: OAuthScopes = get_edited_object()
				#var toggled = scopes.used_scopes.find(scope.value) != -1;
				#checkbox.button_pressed = toggled;
				checkbox.toggled.connect(_on_checkbox_pressed.bind(scope))
				checkbox.tooltip_text = scope.description
				_scope_checkboxes[scope.value] = checkbox
				grid.add_child(checkbox);
				add_focusable(checkbox);
		add_child(grid);


	func _on_scope_changed() -> void:
		update_property()


	func _update_property() -> void:
		for scope: StringName in _scope_checkboxes.keys():
			var checkbox: CheckBox = _scope_checkboxes[scope];
			var scopes: OAuthScopes = get_edited_object()
			checkbox.button_pressed = scopes.used_scopes.find(scope) != -1;


	func _on_checkbox_pressed(toggled_on: bool, scope: TwitchScope.Definition) -> void:
		var scopes: OAuthScopes = get_edited_object()
		if toggled_on:
			if scopes.used_scopes.find(scope.value) == -1:
				scopes.used_scopes.append(scope.value)
		else:
			scopes.used_scopes.erase(scope.value)
		emit_changed("used_scopes", scopes.used_scopes, &"", true)
