## Tests for [TwitchEventListener].
##
## Two things are covered here: the conditions that the selected subscription
## defines (the part the inspector renders) and [method TwitchEventListener.ensure_subscription],
## which decides at runtime whether the node has to subscribe on its own.
##
## No network is involved. [method TwitchEventsub.subscribe] appends to its
## subscription list synchronously and only the transport afterwards needs a
## session, so the decision logic is observable without one.
extends TwitcherTest

const FOLLOW := TwitchEventsubDefinition.Type.CHANNEL_FOLLOW
const SUBSCRIBE := TwitchEventsubDefinition.Type.CHANNEL_SUBSCRIBE

const FOLLOW_CONDITION := {
	&"broadcaster_user_id": "123",
	&"moderator_user_id": "456",
}


func _make_listener(type: TwitchEventsubDefinition.Type, condition: Dictionary = {}) -> TwitchEventListener:
	var listener: TwitchEventListener = autofree(TwitchEventListener.new())
	listener.subscription = type
	listener.condition = condition.duplicate()
	return listener


func _make_eventsub() -> TwitchEventsub:
	var eventsub: TwitchEventsub = add_child_autofree(TwitchEventsub.new())
	# The test client is only added to the tree when the test server is enabled,
	# so nothing else would ever free it.
	autofree(eventsub.get_test_client())
	return eventsub


#region Conditions

func test_selecting_a_subscription_defines_its_conditions() -> void:
	var listener: TwitchEventListener = autofree(TwitchEventListener.new())

	listener.subscription = FOLLOW

	assert_eq(
		listener.condition.keys(), [&"broadcaster_user_id", &"moderator_user_id"],
		"the selected type has to define which conditions are editable"
	)


func test_switching_the_subscription_keeps_the_values_of_shared_conditions() -> void:
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)

	listener.subscription = SUBSCRIBE

	assert_eq(
		listener.condition, { &"broadcaster_user_id": "123" },
		"channel.subscribe only needs the broadcaster, the moderator has to be dropped"
	)


func test_get_conditions_prefers_the_user_that_got_selected_in_the_editor() -> void:
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)
	var user: TwitchUser = TwitchUser.new()
	user.id = "999"
	listener.set_meta(&"broadcaster_user_id_user", user)

	assert_eq(
		listener.get_conditions(),
		{ &"broadcaster_user_id": "999", &"moderator_user_id": "456" },
		"the resolved user wins over the plain value"
	)


func test_missing_conditions_lists_every_empty_condition() -> void:
	var listener := _make_listener(FOLLOW, { &"broadcaster_user_id": "123" })

	assert_eq(
		listener.get_missing_conditions(), [&"moderator_user_id"] as Array[StringName],
		"a condition without a value can't be used to subscribe"
	)


func test_a_configuration_warning_is_shown_for_missing_conditions() -> void:
	var complete := _make_listener(FOLLOW, FOLLOW_CONDITION)
	var incomplete := _make_listener(FOLLOW)

	assert_eq(complete._get_configuration_warnings().size(), 0,
		"filled conditions are fine")
	assert_eq(incomplete._get_configuration_warnings().size(), 1,
		"empty conditions need a hint that the eventsub has to be configured")

#endregion

#region Ensure subscription

func test_subscribes_when_the_eventsub_has_no_subscription() -> void:
	var eventsub := _make_eventsub()
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)
	listener.eventsub = eventsub

	listener.ensure_subscription()

	var subscriptions: Array[TwitchEventsubConfig] = eventsub.get_subscriptions()
	assert_eq(subscriptions.size(), 1, "the listener has to subscribe on its own")
	assert_eq(subscriptions[0].type, FOLLOW, "subscribed to the wrong type")
	assert_eq(subscriptions[0].get_conditions(), FOLLOW_CONDITION,
		"the conditions of the node have to be used to subscribe")


func test_subscribes_on_ready() -> void:
	var eventsub := _make_eventsub()
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)
	listener.eventsub = eventsub

	add_child(listener)
	await wait_frames(1)

	assert_eq(eventsub.get_subscriptions().size(), 1,
		"a listener that enters the tree has to ensure its subscription")


func test_does_not_subscribe_twice_for_the_same_conditions() -> void:
	var eventsub := _make_eventsub()
	eventsub.subscribe(TwitchEventsubConfig.create(
		TwitchEventsubDefinition.CHANNEL_FOLLOW, FOLLOW_CONDITION.duplicate()))
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)
	listener.eventsub = eventsub

	listener.ensure_subscription()

	assert_eq(eventsub.get_subscriptions().size(), 1,
		"an existing subscription with the same conditions is enough")


func test_subscribes_when_the_existing_subscription_has_other_conditions() -> void:
	var eventsub := _make_eventsub()
	eventsub.subscribe(TwitchEventsubConfig.create(
		TwitchEventsubDefinition.CHANNEL_FOLLOW,
		{ &"broadcaster_user_id": "999", &"moderator_user_id": "999" }))
	var listener := _make_listener(FOLLOW, FOLLOW_CONDITION)
	listener.eventsub = eventsub

	listener.ensure_subscription()

	assert_eq(eventsub.get_subscriptions().size(), 2,
		"another broadcaster is another subscription")


func test_does_not_subscribe_without_conditions() -> void:
	var eventsub := _make_eventsub()
	var listener := _make_listener(FOLLOW)
	listener.eventsub = eventsub

	listener.ensure_subscription()

	assert_eq(eventsub.get_subscriptions().size(), 0,
		"without conditions there is nothing to subscribe with")


func test_accepts_a_foreign_subscription_when_conditions_are_missing() -> void:
	var eventsub := _make_eventsub()
	eventsub.subscribe(TwitchEventsubConfig.create(
		TwitchEventsubDefinition.CHANNEL_FOLLOW, FOLLOW_CONDITION.duplicate()))
	var listener := _make_listener(FOLLOW)
	listener.eventsub = eventsub

	listener.ensure_subscription()

	assert_eq(eventsub.get_subscriptions().size(), 1,
		"the subscription got configured on the eventsub, that stays supported"
	)

#endregion
