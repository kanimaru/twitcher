## Tests for [TwitchEventsub].
##
## No network is involved. Subscribing only appends to the subscription list and
## queues an action that waits for a session, so the list itself is observable
## without a connection.
extends TwitcherTest

const FOLLOW_CONDITION: Dictionary = {
	&"broadcaster_user_id": "123",
	&"moderator_user_id": "456",
}


func _make_eventsub() -> TwitchEventsub:
	var eventsub: TwitchEventsub = add_child_autofree(TwitchEventsub.new())
	# The test client is only added to the tree when the test server is enabled,
	# so nothing else would ever free it.
	autofree(eventsub.get_test_client())
	return eventsub


func _subscribe_follows(eventsub: TwitchEventsub, count: int) -> void:
	for index: int in count:
		var condition: Dictionary = FOLLOW_CONDITION.duplicate()
		condition[&"broadcaster_user_id"] = str(index)
		eventsub.subscribe(TwitchEventsubConfig.create(
				TwitchEventsubDefinition.CHANNEL_FOLLOW, condition))


#region Unsetup

## Regression test: [method TwitchEventsub.do_unsetup] iterated the subscription
## list while [method TwitchEventsub.unsubscribe] erased from it, so every second
## subscription was skipped and stayed active at Twitch after logging out.
func test_unsetup_unsubscribes_every_subscription() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()
	_subscribe_follows(eventsub, 4)

	eventsub.do_unsetup()

	assert_eq(eventsub.get_subscriptions().size(), 0,
		"every subscription has to be removed, not every second one")

#endregion


#region Server URLs

## Regression test: the URLs were copied to the clients in [code]_init[/code]
## only. Exported values are assigned afterwards, so a proxy configured in the
## inspector was never used.
func test_the_live_server_url_is_applied_to_the_client() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.eventsub_live_server_url = "ws://127.0.0.1:1/proxy"

	assert_eq(eventsub.get_client().connection_url, "ws://127.0.0.1:1/proxy")


func test_the_test_server_url_is_applied_to_the_test_client() -> void:
	var eventsub: TwitchEventsub = _make_eventsub()

	eventsub.eventsub_test_server_url = "ws://127.0.0.1:2/cli"

	assert_eq(eventsub.get_test_client().connection_url, "ws://127.0.0.1:2/cli")


func test_a_url_from_a_scene_file_is_applied_to_the_client() -> void:
	var scene: PackedScene = PackedScene.new()
	var original: TwitchEventsub = autofree(TwitchEventsub.new())
	autofree(original.get_client())
	autofree(original.get_test_client())
	original.eventsub_live_server_url = "ws://127.0.0.1:3/scene"
	scene.pack(original)

	var loaded: TwitchEventsub = add_child_autofree(scene.instantiate())
	autofree(loaded.get_test_client())

	assert_eq(loaded.get_client().connection_url, "ws://127.0.0.1:3/scene")

#endregion
