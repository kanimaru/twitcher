@tool
extends HBoxContainer

class_name UserConverter

const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchTweens = preload("res://addons/twitcher/editor/twitch_tweens.gd")

@onready var _login: LineEdit = %Login
@onready var _id: LineEdit = %Id
@onready var _swap_view: Button = %SwapView
@onready var search: Button = %Search
@onready var _use_default_user: Button = %UseDefaultUser

@export var user: TwitchUser
@export var token: OAuthToken
@export var setting: OAuthSetting
## Fills the field with the default user when it is shown empty. Turn it off wherever an empty
## field means something, e.g. eventsub conditions where Twitch takes only one of several user
## ids (channel.raid). The default user button keeps working either way.
@export var auto_fill_default_user: bool = true
## Shows a small button that puts the default user into the field on request.
@export var show_default_user_button: bool = true:
	set = _update_show_default_user_button

static var _current_user: TwitchUser

var user_login: String:
	set = _update_user_login

var user_id: String:
	set = _update_user_id

## Where the default user comes from, swap it to feed the converter without editor settings.
var default_user_source: TwitchDefaultUserSource = TwitchDefaultUserSource.new()
## Looks a user up on Twitch: [code]Callable(opt: TwitchGetUsers.Opt) -> TwitchUser[/code], may be
## a coroutine. Asks the Twitch API when unset.
var user_lookup: Callable


signal changed(user: TwitchUser)


func _ready() -> void:
	_login.text_changed.connect(_on_login_changed)
	_login.text_submitted.connect(_on_text_submitted)
	_login.focus_exited.connect(_on_focus_exited)
	_id.text_changed.connect(_on_id_changed)
	_id.text_submitted.connect(_on_text_submitted)
	_id.focus_exited.connect(_on_focus_exited)
	_swap_view.pressed.connect(_on_swap_view)
	search.pressed.connect(_on_search_pressed)
	_use_default_user.pressed.connect(use_default_user)
	_use_default_user.visible = show_default_user_button
	_refresh_default_user_button()
	_load_default_user.call_deferred()


func update_user(new_user: TwitchUser, notify: bool = false) -> void:
	if new_user:
		user_login = new_user.login
		user_id = new_user.id
	else:
		user_login = ""
		user_id = ""
	user = new_user
	if is_node_ready():
		_refresh_default_user_button()
	if notify: changed.emit(new_user)


## Puts the default user into the field and reports the change. Flashes red when there is no
## default user configured.
func use_default_user() -> void:
	var default_user: TwitchUser = default_user_source.get_user()
	if default_user == null:
		TwitchTweens.flash(self, Color.RED)
		return
	update_user(default_user, true)


## Experimental tries to load default user
func _load_default_user() -> void:
	if not auto_fill_default_user or user_login or user_id:
		return
	if not default_user_source.is_auto_fill_enabled():
		return
	_current_user = default_user_source.get_user()
	if _current_user:
		update_user(_current_user, true)


## Experimental tries to load user from api key
func load_current_user() -> void:
	if _current_user == null:
		var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
		_current_user = await _load_user(users)

	if _current_user \
		and not user_login \
		and not user_id \
		and default_user_source.is_auto_fill_enabled():
		update_user(_current_user, true)


func _on_swap_view() -> void:
	if _login.visible:
		_login.visible = false
		_id.visible = true
		_swap_view.text = "ID"
	else:
		_login.visible = true
		_id.visible = false
		_swap_view.text = "Name"


func _update_user_login(val: String) -> void:
	user_login = val
	_login.text = val
	_login.caret_column = val.length()


func _update_user_id(val: String) -> void:
	user_id = val
	_id.text = val
	_id.caret_column = val.length()


func _update_show_default_user_button(val: bool) -> void:
	show_default_user_button = val
	if is_node_ready():
		_use_default_user.visible = val


## The button is only an icon, so its tooltip names the user it puts in, and it is disabled when
## pressing it would change nothing.
func _refresh_default_user_button() -> void:
	var default_user: TwitchUser = default_user_source.get_user()
	if default_user == null:
		_use_default_user.disabled = true
		_use_default_user.tooltip_text = "No default user, set one up in the Twitcher setup."
	elif user != null and user.id == default_user.id:
		_use_default_user.disabled = true
		_use_default_user.tooltip_text = "Already the default user %s." % default_user.login
	else:
		_use_default_user.disabled = false
		_use_default_user.tooltip_text = "Use the default user %s." % default_user.login


func _on_id_changed(new_text: String) -> void:
	_login.text = ""
	TwitchTweens.loading(self, Color.AQUA)


func _on_login_changed(new_text: String) -> void:
	_id.text = ""
	TwitchTweens.loading(self, Color.AQUA)


func reload() -> void:
	var new_user_login: String = _login.text
	var new_user_id: String = _id.text
	if new_user_id == "" and new_user_login == "":
		await TwitchTweens.flash(self, Color.GREEN)
		changed.emit(null)
		return


	if user and new_user_login == user.login and new_user_id == user.id:
		return

	var users: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()

	if new_user_login != "" and (not user or user.login != new_user_login):
		users.login = [ new_user_login ]
	elif new_user_id != "" and (not user or user.id != new_user_id):
		users.id = [ new_user_id ]

	var new_user: TwitchUser = await _load_user(users)
	if new_user != null: update_user(new_user, true)


func _load_user(users: TwitchGetUsers.Opt) -> TwitchUser:
	TwitchTweens.loading(self)
	if users.id != null or users.login != null:
		var lookup: Callable = user_lookup if user_lookup.is_valid() else _get_user
		var new_user: TwitchUser = await lookup.call(users)
		if not new_user:
			await TwitchTweens.flash(self, Color.RED)
		else:
			await TwitchTweens.flash(self, Color.GREEN)
		return new_user
	return null


func _on_focus_exited() -> void:
	reload()


func _on_text_submitted(new_text: String) -> void:
	reload()


func _on_search_pressed() -> void:
	reload()


func _get_user(get_user_opt: TwitchGetUsers.Opt) -> TwitchUser:
	var api: TwitchAPI = TwitchAPI.new()
	var _token: OAuthToken = token if token else TwitchEditorSettings.editor_oauth_token
	var _setting: OAuthSetting = setting if setting else TwitchEditorSettings.editor_oauth_setting
	api.token = _token
	api.oauth_setting = _setting
	add_child(api)
	var response: TwitchGetUsers.Response = await api.get_users(get_user_opt)
	var data: Array[TwitchUser] = response.data
	if data.is_empty():
		printerr("User %s%s was not found." % [ get_user_opt.login, get_user_opt.id ])
		return null
	remove_child(api)
	return data[0]
