@tool
extends Node

const SettingTweens = preload("res://addons/twitcher/settings/setting_tweens.gd")

@onready var clear_emotes: Button = %ClearEmotes
@onready var clear_badges: Button = %ClearBadges

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_badges.pressed.connect(_on_clear_badges)
	clear_emotes.pressed.connect(_on_clear_emotes)

func _on_clear_badges() -> void:
	var clear_result = TwitchSetting.cache_clear_badges()
	if clear_result["result"] != OK:
		push_error("Couldn't delete %s in %s cause of %s" % [clear_result["file"], clear_result["folder"], error_string(clear_result["result"])])
		SettingTweens.flash(clear_badges, Color.ORANGE_RED)
	else:
		SettingTweens.flash(clear_badges, Color.LAWN_GREEN)

func _on_clear_emotes() -> void:
	var clear_result = TwitchSetting.cache_clear_emotes()
	if clear_result["result"] != OK:
		push_error("Couldn't delete %s in %s cause of %s" % [clear_result["file"], clear_result["folder"], error_string(clear_result["result"])])
		SettingTweens.flash(clear_emotes, Color.ORANGE_RED)
	else:
		SettingTweens.flash(clear_emotes, Color.LAWN_GREEN)
