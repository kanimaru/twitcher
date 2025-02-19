extends Control

const CLIP_THUMBNAIL = preload("res://example/clip_viewer/clip_thumbnail.tscn")

var _log = TwitchLogger.new("ClipThumbnail")

@onready var twitch_api: TwitchAPI = %TwitchAPI
@onready var username: LineEdit = %Username
@onready var clip_container: GridContainer = %ClipContainer
@onready var twitch_media_loader: TwitchMediaLoader = %TwitchMediaLoader
@onready var debounce: Timer = %Debounce

var _selected_username: String


func _ready() -> void:
	_log.enabled = true
	username.text_changed.connect(_on_text_changed)
	debounce.timeout.connect(load_users_clips)


func _on_text_changed(new_text: String) -> void:
	_selected_username = new_text
	debounce.start()


func load_users_clips() -> void:
	_log.i("Load Clips from %s" % _selected_username)
	debounce.stop()
	var user: TwitchGetUsersResponse = await twitch_api.get_users([], [_selected_username])
	if user.data.is_empty():
		_log.i("No clips found")
		_clear_clips()
		return
	
	var clips: TwitchGetClipsResponse = await twitch_api.get_clips_opt({}, user.data[0].id)
	_show_clips(clips)


func _show_clips(clips: TwitchGetClipsResponse) -> void:
	_log.i("Show %s clips" % clips.data.size())
	
	for clip: TwitchClip in clips.data:
		var image: Image = await twitch_media_loader.load_image(clip.thumbnail_url)
		var texture2d: ImageTexture = ImageTexture.new()
		texture2d.set_image(image)
		var thumbnail = CLIP_THUMBNAIL.instantiate()
		thumbnail.title = clip.title
		thumbnail.texture = texture2d
		thumbnail.clicked.connect(_on_thumbnail_clicked.bind(clip))
		clip_container.add_child(thumbnail)


func _clear_clips() -> void:
	for child in clip_container.get_children():
		child.queue_free()


func _on_thumbnail_clicked(clip: TwitchClip) -> void:
	print("Clicked on: ", clip)
