@tool
extends RefCounted

class_name TwitchSendExtensionPubSubMessageBody

## The target of the message. Possible values are:      * broadcast * global * whisper-<user-id>    If `is_global_broadcast` is **true**, you must set this field to global. The broadcast and global values are mutually exclusive; specify only one of them.
var target: Array[String];
## The ID of the broadcaster to send the message to. Don’t include this field if `is_global_broadcast` is set to **true**.
var broadcaster_id: String;
## A Boolean value that determines whether the message should be sent to all channels where your extension is active. Set to **true** if the message should be sent to all channels. The default is **false**.
var is_global_broadcast: bool;
## The message to send. The message can be a plain-text string or a string-encoded JSON object. The message is limited to a maximum of 5 KB.
var message: String;

static func from_json(d: Dictionary) -> TwitchSendExtensionPubSubMessageBody:
	var result = TwitchSendExtensionPubSubMessageBody.new();
	result.target = d["target"];
	result.broadcaster_id = d["broadcaster_id"];
	result.is_global_broadcast = d["is_global_broadcast"];
	result.message = d["message"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["target"] = target;
	d["broadcaster_id"] = broadcaster_id;
	d["is_global_broadcast"] = is_global_broadcast;
	d["message"] = message;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

