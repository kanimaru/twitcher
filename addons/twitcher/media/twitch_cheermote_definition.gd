extends RefCounted

## Definition of a specific cheermote
class_name TwitchCheermoteDefinition

const THEME_DARK: StringName = &"dark"
const THEME_LIGHT: StringName = &"light"

const TYPE_ANIMATED: StringName = &"animated_format"
const TYPE_STATIC: StringName = &"static_format"

const SCALE_1: StringName = &"1"
const SCALE_2: StringName = &"2"
const SCALE_3: StringName = &"3"
const SCALE_4: StringName = &"4"
const SCALE_1_5: StringName = &"1.5"

const SCALE_MAP: Dictionary[float, StringName] = {
	1: SCALE_1, 2: SCALE_2, 3: SCALE_3, 4: SCALE_4, 1.5: SCALE_1_5
}

var prefix: String
var tier: StringName
var theme: StringName = THEME_DARK
var type: StringName = TYPE_ANIMATED
var scale: StringName = SCALE_1


func _init(pre: String, tir: String) -> void:
	prefix = pre
	tier = tir

func theme_dark() -> TwitchCheermoteDefinition: theme = THEME_DARK; return self;
func theme_light() -> TwitchCheermoteDefinition: theme = THEME_LIGHT; return self;

func type_animated() -> TwitchCheermoteDefinition: type = TYPE_ANIMATED; return self;
func type_static() -> TwitchCheermoteDefinition: type = TYPE_STATIC; return self;

func scale_1() -> TwitchCheermoteDefinition: scale = SCALE_1; return self;
func scale_2() -> TwitchCheermoteDefinition: scale = SCALE_2; return self;
func scale_3() -> TwitchCheermoteDefinition: scale = SCALE_3; return self;
func scale_4() -> TwitchCheermoteDefinition: scale = SCALE_4; return self;
func scale_1_5() -> TwitchCheermoteDefinition: scale = SCALE_1_5; return self;


func _to_string() -> String:
	return "Cheer[%s/%s]" % [prefix, tier]

func get_id() -> String:
	return "/" + "/".join([ prefix, tier, theme, type, scale ])
