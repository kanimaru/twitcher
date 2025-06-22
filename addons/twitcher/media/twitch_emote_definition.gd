extends RefCounted

## Used to define what emotes to load to be typesafe and don't request invalid data.
class_name TwitchEmoteDefinition

var id: String
var scale: int
var type: StringName
var theme: StringName

const SCALE_1: int = 1
const SCALE_2: int = 2
const SCALE_3: int = 3

const TYPE_DEFAULT: StringName = &"default"
const TYPE_STATIC: StringName = &"static"
const TYPE_ANIMATED: StringName = &"animated"

const THEME_DARK: StringName = &"dark"
const THEME_LIGHT: StringName = &"light"

func _init(emote_id: String) -> void:
	id = emote_id
	scale_1().type_default().theme_dark()

func scale_1() -> TwitchEmoteDefinition: scale = SCALE_1; return self;
func scale_2() -> TwitchEmoteDefinition: scale = SCALE_2; return self;
func scale_3() -> TwitchEmoteDefinition: scale = SCALE_3; return self;

func type_default() -> TwitchEmoteDefinition: type = TYPE_DEFAULT; return self;
func type_static() -> TwitchEmoteDefinition: type = TYPE_STATIC; return self;
func type_animated() -> TwitchEmoteDefinition: type = TYPE_ANIMATED; return self;

func theme_dark() -> TwitchEmoteDefinition: theme = THEME_DARK; return self;
func theme_light() -> TwitchEmoteDefinition: theme = THEME_LIGHT; return self;

func _to_string() -> String:
	return "Emote[%s]" % id

## Returns its unique filename
func get_file_name() -> String:
	return "%s_%s_%s_%s" % [scale, type, theme, id]
