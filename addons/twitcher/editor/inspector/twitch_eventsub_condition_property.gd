extends EditorProperty

## Shows the conditions of an eventsub subscription as inputs.
## Works for every object that provides the [TwitchEventsubDefinition] via `definition` and holds
## the values within a `condition` dictionary. (See [TwitchEventsubConfig] and [TwitchEventListener])

const USER_CONVERTER = preload("res://addons/twitcher/editor/inspector/user_converter.tscn")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")

var _container: Node = GridContainer.new()
## Guard against rebuilding the inputs while they are rebuild already
var _updating: bool

func _init():
	_container.columns = 2
	add_child(_container)
	set_bottom_editor(_container)


## Object that holds the `definition` and the `condition` dictionary
func _get_target() -> Object:
	var target: Object = get_edited_object()
	if target == null || target.get_class() == &"EditorDebuggerRemoteObject": return null
	return target


func _cleanup_unused_meta() -> void:
	var target: Object = _get_target()
	if target == null: return

	var conditions: Array[StringName] = target.definition.conditions
	var unused_conditions: Array = target.get_meta_list() \
		.filter(func(cond: StringName):
			var is_user_property: bool = cond.ends_with("_user")
			var condition_not_found: bool = conditions.find(cond.trim_suffix("_user")) == -1
			return is_user_property && condition_not_found)

	for unused_condition: StringName in unused_conditions:
		target.remove_meta(unused_condition)


func _update_property() -> void:
	if _updating: return
	_updating = true
	_cleanup_unused_meta()
	_clean_conditions()
	_create_conditions()
	_updating = false


func _clean_conditions() -> void:
	for node in _container.get_children():
		_container.remove_child(node)
		node.queue_free()


func _create_conditions() -> void:
	var target: Object = _get_target()
	if target == null: return

	for condition_name: StringName in target.definition.conditions:
		var condition_value: String = str(target.condition.get(condition_name, ""))
		_create_condition_title(condition_name)

		var editor_token: OAuthToken = TwitchEditorSettings.editor_oauth_token
		if condition_name.to_lower().ends_with("user_id") and editor_token.is_token_valid():
			_create_editor_supported_input(target, condition_name, condition_value)
		else:
			_create_manual_input(condition_name, condition_value)


func _create_condition_title(condition_name: String) -> void:
	var condition_title: Label = Label.new()
	condition_title.text = condition_name.capitalize()
	_container.add_child(condition_title)


func _create_editor_supported_input(target: Object, \
		condition_name: String, \
		condition_value: String) -> void:
	var user_converter: UserConverter = USER_CONVERTER.instantiate()
	user_converter.changed.connect(_on_changed_user.bind(condition_name))
	_container.add_child(user_converter)

	if target.has_meta(condition_name + "_user"):
		var user: TwitchUser = target.get_meta(condition_name + "_user")
		user_converter.update_user(user)
	elif condition_value != "":
		user_converter.user_id = condition_value
		user_converter.reload()


func _create_manual_input(condition_name: String, condition_value: String) -> void:
	var input: LineEdit = LineEdit.new()
	input.text_submitted.connect(_on_text_submitted.bind(condition_name))
	input.focus_exited.connect(_on_focus_exited.bind(input, condition_name))
	input.text = condition_value
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_container.add_child(input)


func _on_changed_user(user: TwitchUser, condition_name: StringName) -> void:
	var target: Object = _get_target()
	if target == null: return

	if user == null:
		target.remove_meta(condition_name + "_user")
		_change_condition(condition_name, "")
	else:
		target.set_meta(condition_name + "_user", user)
		_change_condition(condition_name, user.id)


func _on_text_submitted(new_text: String, condition_name: StringName) -> void:
	_change_condition(condition_name, new_text)


func _on_focus_exited(input: LineEdit, condition_name: StringName) -> void:
	# Can be triggered while the inputs are rebuild, in that case the value is up to date already.
	if _updating || not is_instance_valid(input) || not input.is_inside_tree(): return
	_change_condition(condition_name, input.text)


## Applies the value on a copy of the conditions so that the change is tracked properly by the
## editor. (Needed to mark scenes / resources as changed)
func _change_condition(condition_name: StringName, value: String) -> void:
	var target: Object = _get_target()
	if target == null: return

	var conditions: Dictionary = target.condition.duplicate()
	if conditions.get(condition_name, null) == value: return
	conditions[condition_name] = value
	emit_changed(&"condition", conditions)
