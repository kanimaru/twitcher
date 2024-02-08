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
	result.aggression = d["aggression"];
	result.bullying = d["bullying"];
	result.disability = d["disability"];
	result.misogyny = d["misogyny"];
	result.overall_level = d["overall_level"];
	result.race_ethnicity_or_religion = d["race_ethnicity_or_religion"];
	result.sex_based_terms = d["sex_based_terms"];
	result.sexuality_sex_or_gender = d["sexuality_sex_or_gender"];
	result.swearing = d["swearing"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["aggression"] = aggression;
	d["bullying"] = bullying;
	d["disability"] = disability;
	d["misogyny"] = misogyny;
	d["overall_level"] = overall_level;
	d["race_ethnicity_or_religion"] = race_ethnicity_or_religion;
	d["sex_based_terms"] = sex_based_terms;
	d["sexuality_sex_or_gender"] = sexuality_sex_or_gender;
	d["swearing"] = swearing;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

