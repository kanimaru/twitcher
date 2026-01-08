extends Control

const TEST_REWARD: TwitchReward = preload("res://addons/twitcher/example/reward/test_reward.tres")

const BTN_ACCEPT: String = "Accept"
const BTN_CANCEL: String = "Cancel"

@onready var api: TwitchAPI = %API
@onready var twitch_media_loader: TwitchMediaLoader = %TwitchMediaLoader
@onready var twitch_redeem_listener: TwitchRedeemListener = %TwitchRedeemListener
@onready var user_redeemed_list: ItemList = %UserRedeemedList
@onready var twitch_service: TwitchService = %TwitchService

var twitch_reward_service: TwitchRewardService


func _ready() -> void:
	twitch_redeem_listener.redeemed.connect(_on_redeem)
	user_redeemed_list.item_clicked.connect(_on_manage_redemption)
	setup_twitcher()
	
	
func setup_twitcher() -> void:
	await twitch_service.setup()
	
	# Register the Reward
	twitch_reward_service = TwitchRewardService.new(api, twitch_media_loader)
	await twitch_reward_service.save_reward(TEST_REWARD)
	
	# Prevent godot from just quitting to actually cleanup the test reward
	get_tree().auto_accept_quit = false
	

# Cleanup the test reward and then quit normally 
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		await twitch_reward_service.delete_reward(TEST_REWARD)
		get_tree().quit()

	
func _on_redeem(redemption: TwitchRedemption) -> void:
	var image: Texture2D = await twitch_media_loader.load_profile_image(redemption.user)
	image.set_size_override(Vector2i(64, 64))
	user_redeemed_list.add_item(redemption.user.display_name, image, false)
	var accept_idx: int = user_redeemed_list.add_item(BTN_ACCEPT)
	user_redeemed_list.set_item_metadata(accept_idx, redemption)
	var cancel_idx: int = user_redeemed_list.add_item(BTN_CANCEL)
	user_redeemed_list.set_item_metadata(cancel_idx, redemption)
	
	
func _on_manage_redemption(idx: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var button: String = user_redeemed_list.get_item_text(idx)
	var redemption: TwitchRedemption = user_redeemed_list.get_item_metadata(idx) as TwitchRedemption
	match button:
		BTN_ACCEPT: 
			user_redeemed_list.remove_item(idx + 1)
			user_redeemed_list.remove_item(idx)
			user_redeemed_list.remove_item(idx - 1)
			redemption.fullfill()
		BTN_CANCEL: 
			user_redeemed_list.remove_item(idx)
			user_redeemed_list.remove_item(idx - 1)
			user_redeemed_list.remove_item(idx - 2)
			redemption.cancel()
