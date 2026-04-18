extends RefCounted

class_name TwitchAnnouncementColor

static var BLUE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("blue")
static var GREEN: TwitchAnnouncementColor = TwitchAnnouncementColor.new("green")
static var ORANGE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("orange")
static var PURPLE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("purple")
static var PRIMARY: TwitchAnnouncementColor = TwitchAnnouncementColor.new("primary")

var value;

static var all_colors: Array[TwitchAnnouncementColor] = [BLUE, GREEN, ORANGE, PURPLE, PRIMARY]
static var by_name: Dictionary[String, TwitchAnnouncementColor] = {
	"blue": BLUE, 
	"green": GREEN, 
	"orange": ORANGE, 
	"purple": PURPLE,
	"primary": PRIMARY
}

enum Enum {
	BLUE, GREEN, ORANGE, PURPLE, PRIMARY
}

func _init(color: String) -> void:
	value = color;
