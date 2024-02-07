extends Resource

class_name TwitchCustomReward

var id: String;
@export var title: String;
@export var cost: int;
@export var prompt: String;
@export var input_required: bool;
@export var pause: bool;
@export var enabled: bool;
@export var auto_complete: bool;

@export var redemption_handler: Script;

func is_dirty(reward: Dictionary) -> bool:
	if reward.title != title: return true;
	if reward.cost != cost: return true;
	if reward.prompt != prompt: return true;
	if reward.is_user_input_required != input_required: return true;
	if reward.is_enabled != enabled: return true;
	if reward.is_paused != pause: return true;
	if reward.should_redemptions_skip_request_queue != auto_complete: return true;
	return false;

func redeem_chat(senderdata : TwitchSenderData, msg : String, badges: Array[SpriteFrames], message: ChatMessage) -> ChatMessage:
	var reward = RefCounted.new();
	reward.set_script(redemption_handler);

	if(reward.has_method("redeem_chat")):
		return reward.redeem_chat(self, senderdata, msg, badges, message);
	return message;

func redeem(data: Variant) -> void:
	var reward = RefCounted.new();
	reward.set_script(redemption_handler);

	if(reward.has_method("redeem")):
		var reward_id = data['reward']['id'];
		var redemption_id = data['id'];
		if auto_complete:
			reward.redeem(self, data);
		else:
			var result = await reward.redeem(self, data) as bool;
			if result: TwitchService.complete_redemption(redemption_id, reward_id);
			else: TwitchService.cancel_redemption(redemption_id, reward_id);
