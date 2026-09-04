## Unit tests for version-aware [TwitchEventsubDefinition] lookup.
##
## Twitch versions subscriptions independently of their name: channel.moderate,
## automod.message.hold, automod.message.update and
## channel.channel_points_automatic_reward_redemption.add each exist at v1 and v2
## under one type string, carrying different payloads.
##
## [code]BY_NAME[/code] is keyed on that type string alone, so those pairs collapse
## onto a single entry and the survivor is whichever was declared last. Resolving an
## incoming notification through it therefore returns the wrong definition half the
## time, and the payload gets decoded by the wrong generated class.
## [method TwitchEventsubDefinition.get_definition] keys on both, which is what the
## eventsub dispatcher uses.
extends TwitcherTest


func _make_notification(type: String, version: String, event: Dictionary) -> TwitchNotificationMessage:
	return TwitchNotificationMessage.new({
		"metadata": {
			"message_id": "msg-1", "message_type": "notification",
			"message_timestamp": "2026-01-01T00:00:00Z",
			"subscription_type": type, "subscription_version": version,
		},
		"payload": {
			"event": event,
			"subscription": {
				"id": "sub-1", "status": "enabled", "type": type, "version": version,
				"cost": 0, "condition": {}, "created_at": "2026-01-01T00:00:00Z",
				"transport": {"method": "websocket", "session_id": "session-1"},
			},
		},
	})


## The one field EventV2 adds over Event on channel.moderate, so it doubles as the
## marker for "was this decoded by the right class".
func _moderate_v2_event() -> Dictionary:
	return {
		"broadcaster_user_id": "1", "moderator_user_id": "2", "action": "warn",
		"warn": {
			"user_id": "7", "user_login": "someone", "user_name": "Someone",
			"reason": "spam", "chat_rules_cited": [],
		},
	}


func test_every_definition_is_reachable_by_name_and_version() -> void:
	assert_eq(TwitchEventsubDefinition.BY_NAME_AND_VERSION.size(),
		TwitchEventsubDefinition.ALL.size(),
		"every definition needs a name+version entry, unlike BY_NAME")


func test_by_name_alone_cannot_reach_both_versions() -> void:
	# Documents the collision this lookup exists to work around. If BY_NAME ever
	# grows to full size the extra dictionary has become redundant.
	assert_lt(TwitchEventsubDefinition.BY_NAME.size(), TwitchEventsubDefinition.ALL.size())


func test_get_definition_distinguishes_versions_of_one_type() -> void:
	for pair: Array in [
		["channel.moderate", "1"], ["channel.moderate", "2"],
		["automod.message.hold", "1"], ["automod.message.hold", "2"],
		["automod.message.update", "1"], ["automod.message.update", "2"],
		["channel.channel_points_automatic_reward_redemption.add", "1"],
		["channel.channel_points_automatic_reward_redemption.add", "2"],
	]:
		var definition := TwitchEventsubDefinition.get_definition(pair[0], pair[1])
		assert_not_null(definition, "%s v%s" % pair)
		assert_eq(definition.value, StringName(pair[0]))
		assert_eq(definition.version, StringName(pair[1]))


func test_get_definition_falls_back_when_the_version_is_unknown() -> void:
	# Twitch shipping a version we have not generated yet should degrade to the
	# name match rather than returning null and crashing the dispatcher.
	var definition := TwitchEventsubDefinition.get_definition("channel.moderate", "99")
	assert_not_null(definition)
	assert_eq(definition.value, &"channel.moderate")


func test_get_definition_returns_null_for_an_unknown_type() -> void:
	assert_null(TwitchEventsubDefinition.get_definition("not.a.subscription", "1"))


func test_get_event_class_picks_the_version_specific_class() -> void:
	# Two upstream naming conventions reach the same place: EventV2 on the automod
	# and moderate schemas, V2Event on the automatic reward one.
	var expected := {
		["channel.moderate", "1"]: "Event",
		["channel.moderate", "2"]: "EventV2",
		["automod.message.hold", "2"]: "EventV2",
		["channel.channel_points_automatic_reward_redemption.add", "2"]: "V2Event",
		# No version specific class exists for these - documented fallback to Event.
		["channel.chat.message", "1"]: "Event",
		["channel.guest_star_session.begin", "beta"]: "Event",
	}
	for pair: Array in expected:
		var definition := TwitchEventsubDefinition.get_definition(pair[0], pair[1])
		var event_class: Variant = definition.get_event_class()
		assert_not_null(event_class, "%s v%s" % pair)
		var constants: Dictionary = definition.response_script.get_script_constant_map()
		assert_eq(constants.get(expected[pair]), event_class,
			"%s v%s should decode with %s" % [pair[0], pair[1], expected[pair]])


func test_v2_notification_keeps_v2_only_payload_fields() -> void:
	var event := TwitchEventsub.Event.new(
		_make_notification("channel.moderate", "2", _moderate_v2_event()))

	assert_eq(event.type.version, &"2", "resolved definition must be the v2 one")
	var typed: Variant = event.typed_data
	assert_true("warn" in typed, "v2 payload must decode with EventV2")
	assert_eq(typed.warn.reason, "spam", "v2-only data must survive parsing")


func test_v1_notification_still_decodes_with_the_v1_class() -> void:
	var event := TwitchEventsub.Event.new(
		_make_notification("channel.moderate", "1", _moderate_v2_event()))

	assert_eq(event.type.version, &"1")
	assert_true(event.type.documentation_link.ends_with("#channelmoderate"))
	assert_false("warn" in event.typed_data, "v1 class has no warn field")
