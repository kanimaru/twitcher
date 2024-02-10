@tool
extends RefCounted

class_name TwitchUpdateAutoModSettingsBody

## The Automod level for hostility involving aggression.
var aggression: int;
## The Automod level for hostility involving name calling or insults.
var bullying: int;
## The Automod level for discrimination against disability.
var disability: int;
## The Automod level for discrimination against women.
var misogyny: int;
## The default AutoMod level for the broadcaster.
var overall_level: int;
## The Automod level for racial discrimination.
var race_ethnicity_or_religion: int;
## The Automod level for sexual content.
var sex_based_terms: int;
## The AutoMod level for discrimination based on sexuality, sex, or gender.
var sexuality_sex_or_gender: int;
## The Automod level for profanity.
var swearing: int;

static func from_json(d: Dictionary) -> TwitchUpdateAutoModSettingsBody:
	var result = TwitchUpdateAutoModSettingsBody.new();









	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};









	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

