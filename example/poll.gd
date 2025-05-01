extends Control


@onready var twitch_service: TwitchService = %TwitchService
@onready var api: TwitchAPI = %API
@onready var eventsub: TwitchEventsub = %Eventsub

@onready var title: LineEdit = %Title
@onready var answers: VBoxContainer = %Answers
@onready var answer: LineEdit = %Answer
@onready var send: Button = %Send
@onready var channel_point_voting: CheckButton = %ChannelPointVoting
@onready var channel_points: LineEdit = %ChannelPoints
@onready var result_container: GridContainer = %Result
@onready var duration: LineEdit = %Duration

var choice_result: Array[Node] = []

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Please set this settings first before running the example!
# In Node 'TwitchService.OauthSettings' set:
# - ClientID / ClientSecret
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


func _ready() -> void:
	await twitch_service.setup()

	var current_user: TwitchUser = await twitch_service.get_current_user()
	
	twitch_service.subscribe_event(TwitchEventsubDefinition.CHANNEL_POLL_END, {
		&"broadcaster_user_id": current_user.id
	})
	
	send.pressed.connect(_on_send)
	answer.text_changed.connect(_on_answer_changed.bind(answer))
	answer.focus_exited.connect(_on_answer_focus_exited.bind(answer))


func _on_answer_changed(new_text: String, answer: LineEdit) -> void:
	var last_answer: LineEdit = answers.get_children().back()
	
	if new_text.length() > 0 && last_answer == answer || last_answer.text != "":
		var new_answer = answer.duplicate()
		new_answer.text_changed.connect(_on_answer_changed.bind(new_answer))
		new_answer.focus_exited.connect(_on_answer_focus_exited.bind(new_answer))
		new_answer.text = ""
		new_answer.add_to_group(&"answer")
		answer.add_sibling(new_answer)


func _on_answer_focus_exited(answer: LineEdit) -> void:
	if answers.get_child_count() <= 1: return
	if answer.text == "": answer.queue_free()


func _on_send() -> void:
	var title: String = title.text
	
	var answers = get_tree().get_nodes_in_group(&"answer")
	var choices: Array[String] = []
	for answer: LineEdit in answers:
		var text: String = answer.text
		if text == "": continue
		choices.append(text)
		
	var channel_point_voting_enabled: bool = channel_point_voting.button_pressed
	var channel_point: int = int(channel_points.text)
	var dur = int(duration.text)
	var result = await twitch_service.poll(title, choices, dur, channel_point_voting_enabled, channel_point)
	
	_clear_choices()
	var result_choices = result["choices"]
	for choice in result_choices:
		var choice_title: Label = Label.new()
		choice_title.text = choice["title"]
		
		var channel_point_votes: Label = Label.new()
		channel_point_votes.text = str(choice["channel_points_votes"])
		
		var votes: Label = Label.new()
		votes.text = str(choice["votes"])
		
		choice_result.append(choice_title)
		choice_result.append(channel_point_votes)
		choice_result.append(votes)
		
		result_container.add_child(choice_title)
		result_container.add_child(channel_point_votes)
		result_container.add_child(votes)


func _clear_choices() -> void:
	for choice in choice_result:
		choice.queue_free()
