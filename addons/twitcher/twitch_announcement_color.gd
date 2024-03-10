extends RefCounted

class_name TwitchAnnouncementColor

static var BLUE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("blue")
static var GREEN: TwitchAnnouncementColor = TwitchAnnouncementColor.new("green")
static var ORANGE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("orange")
static var PURPLE: TwitchAnnouncementColor = TwitchAnnouncementColor.new("purple")
static var PRIMARY: TwitchAnnouncementColor = TwitchAnnouncementColor.new("primary")

var value;

func _init(color: String) -> void:
	value = color;
