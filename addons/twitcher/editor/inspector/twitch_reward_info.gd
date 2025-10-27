@tool
extends Control

const TwitchIcon = preload("res://addons/twitcher/editor/inspector/twitch_icon.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchEditorNodeUtils = preload("res://addons/twitcher/editor/twitch_editor_node_utils.gd")
const TwitchRewardEditorService = preload("res://addons/twitcher/editor/inspector/twitch_reward_editor_service.gd")

# For checking if the cooldown time is in minutes or days
const MINUTE_IN_SEC: int = 60
const HOUR_IN_SEC: int = 60 * MINUTE_IN_SEC
const DAY_IN_SEC: int = 24 * HOUR_IN_SEC

# Consts for the CooldownTimeUnit indices
const CD_UNIT_SECONDS: int = 0
const CD_UNIT_MINUTE: int = 1
const CD_UNIT_HOUR: int = 2
const CD_UNIT_DAY: int = 3

@export var token: OAuthToken
@export var setting: OAuthSetting

@onready var id: Label = %ID
@onready var title: LineEdit = %Title
@onready var description: TextEdit = %Description
@onready var require_viewer_text: CheckButton = %RequireViewerText
@onready var cost: SpinBox = %Cost
@onready var icon_28: TwitchIcon = %Icon28
@onready var icon_56: TwitchIcon = %Icon56
@onready var icon_112: TwitchIcon = %Icon112
@onready var background_color: ColorPickerButton = %BackgroundColor
@onready var skip_reward_queue: CheckButton = %SkipRewardQueue
@onready var cooldown_time: SpinBox = %CooldownTime
@onready var cooldown_time_unit: OptionButton = %CooldownTimeUnit
@onready var limit_per_stream: SpinBox = %LimitPerStream
@onready var limit_per_stream_per_user: SpinBox = %LimitPerStreamPerUser
@onready var enable: CheckButton = %Enable
@onready var pause: CheckButton = %Pause

@onready var in_stock: CheckButton = %InStock
@onready var current_stream: SpinBox = %CurrentStream
@onready var cooldown_expire_at: Label = %CooldownExpireAt

@onready var load: Button = %Load
@onready var save: Button = %Save
@onready var delete: Button = %Delete


var undo_redo: EditorUndoRedoManager
var twitch_reward: TwitchReward:
	set = _update_twitch_reward
	
var _cooldown_multiplier: int:
	get():
		match cooldown_time_unit.selected:
			CD_UNIT_MINUTE: return MINUTE_IN_SEC
			CD_UNIT_HOUR: return HOUR_IN_SEC
			CD_UNIT_DAY: return DAY_IN_SEC
			_: return 1
			

func _ready() -> void:
	load.pressed.connect(_on_load)
	save.pressed.connect(_on_save)
	delete.pressed.connect(_on_delete)
	
	if twitch_reward == null: return # Happens on bootup
	_update_twitch_reward(twitch_reward)

	# Bind Data Changes to Resource
	enable.toggled.connect(func (state: bool) -> void: twitch_reward.is_enabled = state)
	pause.toggled.connect(func (state: bool) -> void: twitch_reward.is_paused = state)
	title.text_changed.connect(func(text: String) -> void: twitch_reward.title = text)
	description.text_changed.connect(func() -> void: twitch_reward.description = description.text)
	require_viewer_text.toggled.connect(func(state: bool) -> void: twitch_reward.is_user_input_required = state)
	cost.value_changed.connect(func(new_value: float) -> void: twitch_reward.cost = new_value)
	background_color.color_changed.connect(func(new_color: Color) -> void: twitch_reward.background_color = new_color.to_html(false))
	skip_reward_queue.toggled.connect(func(state: bool) -> void: twitch_reward.should_redemptions_skip_request_queue = state)
	cooldown_time.value_changed.connect(func(new_value: float) -> void: 
		twitch_reward.global_cooldown_seconds = new_value * _cooldown_multiplier
		twitch_reward.is_global_cooldown_enabled = twitch_reward.global_cooldown_seconds > 0
	)
	limit_per_stream.value_changed.connect(func(new_value: float) -> void: 
		twitch_reward.max_per_stream = new_value
		twitch_reward.is_max_per_stream_enabled = new_value > 0
	)
	limit_per_stream_per_user.value_changed.connect(func(new_value: float) -> void: 
		twitch_reward.max_per_user_per_stream = new_value
		twitch_reward.is_max_per_user_per_stream_enabled = new_value > 0
	)


func _update_twitch_reward(reward: TwitchReward) -> void:
	if twitch_reward != reward:
		if twitch_reward:
			var old_update_method: Callable = _update_twitch_reward.bind(twitch_reward)
			if twitch_reward.changed.is_connected(old_update_method):
				twitch_reward.changed.disconnect(old_update_method)
			
		twitch_reward = reward
		var update_method: Callable = _update_twitch_reward.bind(reward)
		if not reward.changed.is_connected(update_method):
			reward.changed.connect(update_method)
	
	if not is_node_ready(): return
	if reward == null:
		load.disabled = true
		save.disabled = true
		return
	
	id.text = reward.id if reward.id else "NEW"
	title.text = reward.title
	description.text = reward.description
	require_viewer_text.set_pressed_no_signal(reward.is_user_input_required)
	cost.value = reward.cost
	icon_28.texture = reward.get_image1()
	icon_56.texture = reward.get_image2()
	icon_112.texture = reward.get_image4()
	background_color.color = reward.background_color
	skip_reward_queue.set_pressed_no_signal(reward.should_redemptions_skip_request_queue)
	_update_cooldown(reward.global_cooldown_seconds)
	limit_per_stream.value = reward.max_per_stream
	limit_per_stream_per_user.value = reward.max_per_user_per_stream
	
	enable.set_pressed_no_signal(reward.is_enabled)
	pause.set_pressed_no_signal(reward.is_paused)
	
	in_stock.set_pressed_no_signal(reward.is_in_stock)
	current_stream.set_value_no_signal(reward.redemptions_redeemed_current_stream)
	cooldown_expire_at.text = reward.cooldown_expires_at if reward.cooldown_expires_at else "no data"
	
	delete.disabled = reward.id == ""
	load.disabled = reward.id == ""
	save.disabled = false
	
	
	
func _update_cooldown(cd_in_sec: int) -> void:
	if(fmod(cd_in_sec, DAY_IN_SEC) == 0):
		cooldown_time.value = cd_in_sec / DAY_IN_SEC
		cooldown_time_unit.select(CD_UNIT_DAY)
	elif(fmod(cd_in_sec, HOUR_IN_SEC) == 0):
		cooldown_time.value = cd_in_sec / HOUR_IN_SEC
		cooldown_time_unit.select(CD_UNIT_HOUR)
	elif(fmod(cd_in_sec, MINUTE_IN_SEC) == 0):
		cooldown_time.value = cd_in_sec / MINUTE_IN_SEC
		cooldown_time_unit.select(CD_UNIT_MINUTE)
	else:
		cooldown_time.value = cd_in_sec
		cooldown_time_unit.select(CD_UNIT_SECONDS)
	
#region Twitch Interactions

func _on_load() -> void:
	var api: TwitchAPI = TwitchEditorNodeUtils.create_api(token, setting)
	add_child(api)
	var media_loader: TwitchMediaLoader = TwitchEditorNodeUtils.create_media_loader(api)
	add_child(media_loader)
	var twitch_reward_service: TwitchRewardEditorService = TwitchRewardEditorService.new(api, media_loader)
	await twitch_reward_service.load_reward(twitch_reward)
	api.queue_free()
	media_loader.queue_free()


func _on_save() -> void:
	var api: TwitchAPI = TwitchEditorNodeUtils.create_api(token, setting)
	add_child(api)
	var media_loader: TwitchMediaLoader = TwitchEditorNodeUtils.create_media_loader(api)
	add_child(media_loader)
	var twitch_reward_service: TwitchRewardEditorService = TwitchRewardEditorService.new(api, media_loader)
	await twitch_reward_service.save_reward(twitch_reward)
	api.queue_free()
	media_loader.queue_free()


func _on_delete() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Are you sure you want to delete the reward '%s' on Twitch?" % twitch_reward.title
	dialog.ok_button_text = "Yes"
	dialog.cancel_button_text = "No"
	dialog.title = "Delete Reward"
	dialog.get_ok_button().pressed.connect(func():
		var api: TwitchAPI = TwitchEditorNodeUtils.create_api(token, setting)
		add_child(api)
		var twitch_reward_service: TwitchRewardEditorService = TwitchRewardEditorService.new(api, null)
		await twitch_reward_service.delete_reward(twitch_reward)
		api.queue_free() 
		EditorInterface.get_editor_toaster().push_toast("Deleted reward '%s' succesfully" % twitch_reward.title)
	)
	EditorInterface.popup_dialog_centered(dialog)
	dialog.get_cancel_button().grab_focus()

#endregion
