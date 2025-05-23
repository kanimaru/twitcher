extends RefCounted

## Used to define what emotes to load to be typesafe and don't request invalid data.
class_name TwitchEmoteDefinition

var id: String
var _scale: int
var _type: String
var _theme: String

func _init(emote_id: String) -> void:
	id = emote_id
	scale_1().type_default().theme_dark()

func scale_1() -> TwitchEmoteDefinition: _scale = 1; return self;
func scale_2() -> TwitchEmoteDefinition: _scale = 2; return self;
func scale_3() -> TwitchEmoteDefinition: _scale = 3; return self;

func type_default() -> TwitchEmoteDefinition: _type = "default"; return self;
func type_static() -> TwitchEmoteDefinition: _type = "static"; return self;
func type_animated() -> TwitchEmoteDefinition: _type = "animated"; return self;

func theme_dark() -> TwitchEmoteDefinition: _theme = "dark"; return self;
func theme_light() -> TwitchEmoteDefinition: _theme = "light"; return self;

func _to_string() -> String:
	return "Emote[%s]" % id

## Returns its unique filename
func get_file_name() -> String:
	return "%s_%s_%s_%s" % [_scale, _type, _theme, id]
