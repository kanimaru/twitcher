@tool
extends Control

const TwitchRewardEditorService = preload("res://addons/twitcher/editor/inspector/twitch_reward_editor_service.gd")
const TwitchEditorSettings = preload("res://addons/twitcher/editor/twitch_editor_settings.gd")
const TwitchEditorNodeUtils = preload("res://addons/twitcher/editor/twitch_editor_node_utils.gd")

@onready var file_select: FileSelect = %FileSelect
@onready var fetch_all_rewards: Button = %FetchAllRewards
@onready var fetch_manageable_rewards: Button = %FetchManageableRewards
@onready var info: Label = %Info

@export var token: OAuthToken
@export var setting: OAuthSetting

func _ready() -> void:
	fetch_all_rewards.pressed.connect(_on_fetch_all)
	fetch_manageable_rewards.pressed.connect(_on_fetch_manageable)
	file_select.file_selected.connect(_on_file_selected)
	file_select.path = TwitchEditorSettings.reward_folder
	
	
func _on_file_selected(path: String) -> void:
	TwitchEditorSettings.reward_folder = path
	
	
func _download_rewards(all: bool) -> void:
	var api: TwitchAPI = TwitchEditorNodeUtils.create_api(token, setting)
	add_child(api)
	var media_loader: TwitchMediaLoader = TwitchEditorNodeUtils.create_media_loader(api)
	add_child(media_loader)
	var broadcaster: TwitchUser = await TwitchService.get_current_user_via_api(api)
	var rewards: Array[TwitchCustomReward] = await _fetch_rewards(api, all, broadcaster)
	var twitch_rewards: Array[TwitchReward] = []
	for reward in rewards:
		var twitch_reward: TwitchReward = TwitchReward.new()
		twitch_reward.broadcaster_user = broadcaster
		TwitchRewardEditorService.convert_to_twitch_reward(twitch_reward, reward, media_loader)
		var file_name: String = twitch_reward.title.to_snake_case()
		file_name = RegEx.create_from_string("[^\\w_-]").sub(file_name, "")
		var folder: String = file_select.path
		if not folder: folder = "res://"
		printt(twitch_reward.title, twitch_reward.id)
		
		ResourceSaver.save(twitch_reward, folder + "/" + file_name + ".tres")
	media_loader.queue_free()
	api.queue_free()
	
	
func _fetch_rewards(api: TwitchAPI, all: bool, broadcaster: TwitchUser) -> Array[TwitchCustomReward]:
	if not TwitchEditorSettings.is_valid(): 
		_info("Editor is not authorizd yet. Use 'Test Credentials' from the previous page to authorize the editor.")
		TwitchEditorSettings.editor_oauth_token.authorized.connect(func(): _info(""), CONNECT_ONE_SHOT)
		return []
		
	
	var opt: TwitchGetCustomReward.Opt = TwitchGetCustomReward.Opt.create()
	opt.only_manageable_rewards = not all
	var response: TwitchGetCustomReward.Response = await api.get_custom_reward(opt, broadcaster.id)
	if response.response.response_code == 200:
		return response.data
	var response_data: String = response.response.response_data.get_string_from_utf8()
	_info("Couldn't fetch Rewards cause of %s" % response_data)
	return []

	
func _info(text: String) -> void:
	info.text = text
	
	
func _on_fetch_all() -> void:
	_download_rewards(true)
	
	
func _on_fetch_manageable() -> void:
	_download_rewards(false)
