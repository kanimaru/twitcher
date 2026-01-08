extends Control

## Basic example to show clips of a streamer
## It's not possible to show the clip itself, atleast as much as I know

const CLIP_THUMBNAIL = preload("res://addons/twitcher/example/clip_viewer/clip_thumbnail.tscn")

var _log = TwitchLogger.new("ClipThumbnail")

@onready var twitch_api: TwitchAPI = %TwitchAPI
@onready var username: LineEdit = %Username
@onready var clip_container: GridContainer = %ClipContainer
@onready var twitch_media_loader: TwitchMediaLoader = %TwitchMediaLoader
@onready var search: Button = %Search

var _selected_username: String


func _ready() -> void:
	username.text_submitted.connect(_on_text_changed)
	search.pressed.connect(_on_search)


func _on_text_changed(new_text: String) -> void:
	_selected_username = new_text
	load_users_clips()


func _on_search() -> void:
	load_users_clips()


func load_users_clips() -> void:
	_log.i("Load Clips from %s" % _selected_username)
	var users_opt: TwitchGetUsers.Opt = TwitchGetUsers.Opt.new()
	users_opt.login = [_selected_username]
	var user: TwitchGetUsers.Response = await twitch_api.get_users(users_opt)
	if user.data.is_empty():
		_log.i("No clips found")
		_clear_clips()
		return
	
	var clips_opt: TwitchGetClips.Opt = TwitchGetClips.Opt.new() 
	clips_opt.broadcaster_id = user.data[0].id
	var clips: TwitchGetClips.Response = await twitch_api.get_clips(clips_opt)
	_show_clips(clips)


func _show_clips(clips: TwitchGetClips.Response) -> void:
	_log.i("Show %s clips" % clips.data.size())
	
	for clip: TwitchClip in clips.data:
		var image: Image = await twitch_media_loader.load_image(clip.thumbnail_url)
		var texture2d: ImageTexture = ImageTexture.new()
		texture2d.set_image(image)
		var thumbnail = CLIP_THUMBNAIL.instantiate()
		thumbnail.title = clip.title
		thumbnail.texture = texture2d
		clip_container.add_child(thumbnail)


func _clear_clips() -> void:
	for child in clip_container.get_children():
		child.queue_free()
