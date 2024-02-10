@tool
extends RefCounted

class_name TwitchAutoModSettings

## The broadcaster’s ID.
var broadcaster_id: String;
## The moderator’s ID.
var moderator_id: String;
## The default AutoMod level for the broadcaster. This field is **null** if the broadcaster has set one or more of the individual settings.
var overall_level: int;
## The Automod level for discrimination against disability.
var disability: int;
## The Automod level for hostility involving aggression.
var aggression: int;
## The AutoMod level for discrimination based on sexuality, sex, or gender.
var sexuality_sex_or_gender: int;
## The Automod level for discrimination against women.
var misogyny: int;
## The Automod level for hostility involving name calling or insults.
var bullying: int;
## The Automod level for profanity.
var swearing: int;
## The Automod level for racial discrimination.
var race_ethnicity_or_religion: int;
## The Automod level for sexual content.
var sex_based_terms: int;

static func from_json(d: Dictionary) -> TwitchAutoModSettings:
	var result = TwitchAutoModSettings.new();











	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};











	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

