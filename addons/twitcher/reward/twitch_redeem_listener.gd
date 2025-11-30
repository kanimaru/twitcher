@tool
@icon("res://addons/twitcher/assets/redemption-icon.svg")
extends Twitcher

## Helps to listen for redeems of the viewer
class_name TwitchRedeemListener

static var _log: TwitchLogger = TwitchLogger.new("TwitchRedeemListener")

static var _open_tracked_redemptions: Dictionary[String, TwitchRedemption] = {}

## List of all rewards to listen for.
@export var rewards_to_listen: Array[TwitchReward] = []
## Eventsub to listen for the redemption's. (Can be empty will automatically look for first [TwitchEventsub] 
## in the scene tree)
@export var eventsub: TwitchEventsub
## API to fullfill or deny redemptions. (Can be empty will automatically look for first [TwitchAPI]  in the 
## scene tree)
@export var api: TwitchAPI

## Should the node automatically subscribe to the needed eventsubs in the ready function. 
@export var ensure_subscriptions_on_ready: bool = true

## Called when one of the rewards that this node is listenting is getting redeemed
signal redeemed(redemption: TwitchRedemption)


func _ready() -> void:
	if eventsub == null: eventsub = TwitchEventsub.instance
	if api == null: api = TwitchAPI.instance
	
	eventsub.event_received.connect(_on_event)
	if ensure_subscriptions_on_ready: ensure_subscriptions()
	
	
func ensure_subscriptions() -> void:
	var add_subscriptions: Array[TwitchEventsubConfig] = eventsub.get_subscription_by_type(
		TwitchEventsubDefinition.Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD)
	var update_subscriptions:  Array[TwitchEventsubConfig] = eventsub.get_subscription_by_type(
		TwitchEventsubDefinition.Type.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE)
	var broadcaster: TwitchUser = await TwitchService.get_current_user_via_api(api)
	if add_subscriptions.is_empty():
		var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD, {
			"broadcaster_user_id": broadcaster.id
		})
		eventsub.subscribe(config)
	if update_subscriptions.is_empty():
		var config: TwitchEventsubConfig = TwitchEventsubConfig.create(TwitchEventsubDefinition.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE, {
			"broadcaster_user_id": broadcaster.id
		})
		eventsub.subscribe(config)
		
	
func _on_event(event: TwitchEventsub.Event) -> void:
	if event.type == TwitchEventsubDefinition.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_ADD:
		var redemption_event: TwitchChannelPointsCustomRewardRedemptionAddEvent = TwitchChannelPointsCustomRewardRedemptionAddEvent.from_json(event.data)
		_add_redemption_event(redemption_event)
	elif event.type == TwitchEventsubDefinition.CHANNEL_CHANNEL_POINTS_CUSTOM_REWARD_REDEMPTION_UPDATE:
		var redemption_event: TwitchChannelPointsCustomRewardRedemptionUpdateEvent = TwitchChannelPointsCustomRewardRedemptionUpdateEvent.from_json(event.data)
		if _open_tracked_redemptions.has(redemption_event.id):
			_update_redemption_event(redemption_event)


func _find_by_id(reward: TwitchReward, reward_id_to_search: String) -> bool:
	return reward.id == reward_id_to_search


func _add_redemption_event(redemption_event: TwitchChannelPointsCustomRewardRedemptionAddEvent) -> void:
	var redemption_id: String = redemption_event.id
	var reward_id: String = redemption_event.reward.id
	var idx: int = rewards_to_listen.find_custom(_find_by_id.bind(reward_id))
	if idx == -1: return
	
	var reward = rewards_to_listen[idx]
	var opt = TwitchGetUsers.Opt.new()
	var user_ids: Array[String] = [redemption_event.broadcaster_user_id, redemption_event.user_id]
	opt.id = user_ids
	var users = await api.get_users(opt)
	if users.response.response_code != 200:
		_log.e("Couldn't load users for the redemption of %s" % reward.title)
		return
	var user_idx: int = users.data.find_custom(_by_user_id.bind(redemption_event.user_id))
	var user: TwitchUser = users.data[user_idx]
	var broadcaster_idx: int = users.data.find_custom(_by_user_id.bind(redemption_event.broadcaster_user_id))
	var broadcaster: TwitchUser = users.data[broadcaster_idx]
	var redemption: TwitchRedemption = TwitchRedemption.new(redemption_id, reward, broadcaster, user)
	redemption.redeemed_at = redemption_event.redeemed_at
	redemption.status = redemption_event.status
	redemption.user_input = redemption_event.user_input
	redemption._fullfill_callback = fulfill_redemption
	redemption._cancel_callback = cancel_redemption
	
	_open_tracked_redemptions[redemption_event.id] = redemption
	redeemed.emit(redemption)


func _update_redemption_event(update_event: TwitchChannelPointsCustomRewardRedemptionUpdateEvent) -> void:
	var redemption: TwitchRedemption = _open_tracked_redemptions[update_event.id]
	if redemption.status != TwitchRedemption.Status.UNFULFILLED: return
		
	match update_event.status:
		TwitchRedemption.Status.FULFILLED:
			redemption.notify_fullfilled()
		TwitchRedemption.Status.CANCELED:
			redemption.notify_cancelled()


## Tries to fullfill the redemption in error case it will return null.
func fulfill_redemption(redemption_id: String, reward: TwitchReward, broadcaster_id: String) -> TwitchCustomRewardRedemption:
	return await _update_redemption(true, redemption_id, reward, broadcaster_id)


## Tries to cancel the redemption in error case it will return null.
func cancel_redemption(redemption_id: String, reward: TwitchReward, broadcaster_id: String) -> TwitchCustomRewardRedemption:
	return await _update_redemption(false, redemption_id, reward, broadcaster_id)


func _update_redemption(fullfill: bool, redemption_id: String, reward: TwitchReward, broadcaster_id: String) -> TwitchCustomRewardRedemption:
	var body: TwitchUpdateRedemptionStatus.Body = TwitchUpdateRedemptionStatus.Body.new()
	body.status = "FULFILLED" if fullfill else "CANCELED"
	var response: TwitchUpdateRedemptionStatus.Response = await api.update_redemption_status(body, [redemption_id], reward.id, broadcaster_id)
	if response.response.response_code != 200 || response.data.is_empty():
		return null
	return response.data[0]


func _by_user_id(user: TwitchUser, id: String) -> bool:
	return user.id == id
