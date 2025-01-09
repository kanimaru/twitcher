extends RefCounted

## Definition of a specific cheermote
class_name TwitchCheermoteDefinition


var prefix: String
var tier: String
var theme: String = "dark"
var type: String = "animated_format"
var scale: String = "1"


func _init(pre: String, tir: String) -> void:
	prefix = pre
	tier = tir

func theme_dark() -> TwitchCheermoteDefinition: theme = "dark"; return self;
func theme_light() -> TwitchCheermoteDefinition: theme = "light"; return self;

func type_animated() -> TwitchCheermoteDefinition: type = "animated_format"; return self;
func type_static() -> TwitchCheermoteDefinition: type = "static_format"; return self;

func scale_1() -> TwitchCheermoteDefinition: scale = "1"; return self;
func scale_2() -> TwitchCheermoteDefinition: scale = "2"; return self;
func scale_3() -> TwitchCheermoteDefinition: scale = "3"; return self;
func scale_4() -> TwitchCheermoteDefinition: scale = "4"; return self;
func scale_1_5() -> TwitchCheermoteDefinition: scale = "1.5"; return self;


func get_id() -> String:
	return "/" + "/".join([ prefix, tier, theme, type, scale ])
