## Unit tests for [TwitchScope].
##
## [code]SCOPE_MAP[/code] is a hand-maintained table of ~90 entries mapping the
## Twitch scope string to its [code]Definition[/code]. Hand-maintained tables
## drift, and the failure is silent: a mismatched entry means the OAuth flow
## requests a scope the caller did not ask for, and the resulting 401 surfaces
## somewhere else entirely.
##
## The integrity tests below check the whole table at once, so a future
## copy-paste error is caught by tests that already exist rather than needing a
## new one.
extends TwitcherTest


#region Definition.get_category

func test_get_category_derives_from_prefix_before_colon() -> void:
	var def := TwitchScope.Definition.new(&"channel:read:ads", "desc")
	assert_eq(def.get_category(), "channel")
	def.free()


func test_get_category_prefers_the_explicit_category() -> void:
	var def := TwitchScope.Definition.new(&"chat:read", "desc", "IRC")
	assert_eq(def.get_category(), "IRC", "an explicit category must win over the derived one")
	def.free()


## A scope with no colon has no prefix to strip. [code]find()[/code] returns
## [code]-1[/code] and [code]substr(0, -1)[/code] in Godot means "to the end", so
## the whole value becomes the category — which is the sensible outcome, but it
## arrives by accident rather than by design. Pinned so a future rewrite of
## [code]get_category()[/code] does not quietly change it.
func test_get_category_of_a_scope_with_no_colon_is_the_whole_value() -> void:
	var def := TwitchScope.Definition.new(&"openid", "desc")
	assert_eq(def.get_category(), "openid", "substr(0, -1) returns the full string")
	def.free()


func test_to_string_returns_the_scope_value() -> void:
	var def := TwitchScope.Definition.new(&"bits:read", "desc")
	assert_eq(str(def), "bits:read")
	def.free()

#endregion


#region SCOPE_MAP integrity

## Regression test for a copy-paste swap.
##
## [code]CHAT_READ[/code] and [code]CHAT_EDIT[/code] held each other's values and
## descriptions, so [code]SCOPE_MAP["chat:read"].value[/code] was
## [code]"chat:edit"[/code]. Anyone asking for read access got write access.
##
## This checks the whole table rather than just those two entries, so the next
## swap is caught for free.
func test_every_scope_map_key_matches_its_definition_value() -> void:
	var mismatches: PackedStringArray = []
	for key: String in TwitchScope.SCOPE_MAP:
		var definition: TwitchScope.Definition = TwitchScope.SCOPE_MAP[key]
		if String(definition.value) != key:
			mismatches.append("%s -> %s" % [key, definition.value])

	assert_eq(
		mismatches.size(), 0,
		"SCOPE_MAP keys must equal their definition values, but: " + ", ".join(mismatches)
	)


func test_chat_read_is_the_read_scope() -> void:
	assert_eq(String(TwitchScope.CHAT_READ.value), "chat:read")


func test_chat_edit_is_the_write_scope() -> void:
	assert_eq(String(TwitchScope.CHAT_EDIT.value), "chat:edit")


## The descriptions were swapped along with the values. Checking them separately
## catches a "fix" that only swaps one of the two.
func test_chat_scope_descriptions_match_their_direction() -> void:
	assert_string_contains(
		TwitchScope.CHAT_READ.description.to_lower(), "view",
		"chat:read should be described as viewing"
	)
	assert_string_contains(
		TwitchScope.CHAT_EDIT.description.to_lower(), "send",
		"chat:edit should be described as sending"
	)


func test_scope_map_has_no_null_definitions() -> void:
	for key: String in TwitchScope.SCOPE_MAP:
		assert_not_null(TwitchScope.SCOPE_MAP[key], "SCOPE_MAP[%s] is null" % key)


func test_every_definition_has_a_description() -> void:
	var blank: PackedStringArray = []
	for key: String in TwitchScope.SCOPE_MAP:
		var definition: TwitchScope.Definition = TwitchScope.SCOPE_MAP[key]
		if definition.description.strip_edges() == "":
			blank.append(key)
	assert_eq(blank.size(), 0, "scopes with no description: " + ", ".join(blank))


func test_scope_values_are_unique() -> void:
	var seen: Dictionary[String, bool] = {}
	var duplicates: PackedStringArray = []
	for key: String in TwitchScope.SCOPE_MAP:
		var value := String((TwitchScope.SCOPE_MAP[key] as TwitchScope.Definition).value)
		if seen.has(value):
			duplicates.append(value)
		seen[value] = true
	assert_eq(duplicates.size(), 0, "duplicate scope values: " + ", ".join(duplicates))

#endregion


#region get_all_scopes / get_grouped_scopes

func test_get_all_scopes_covers_the_whole_map() -> void:
	assert_eq(TwitchScope.get_all_scopes().size(), TwitchScope.SCOPE_MAP.size())


func test_get_grouped_scopes_places_every_scope_in_exactly_one_group() -> void:
	var grouped := TwitchScope.get_grouped_scopes()
	var total := 0
	for category: Variant in grouped:
		total += (grouped[category] as Array).size()
	assert_eq(
		total, TwitchScope.SCOPE_MAP.size(),
		"grouping must neither drop nor duplicate scopes"
	)


func test_get_grouped_scopes_groups_by_category() -> void:
	var grouped := TwitchScope.get_grouped_scopes()
	for category: Variant in grouped:
		for definition: TwitchScope.Definition in grouped[category]:
			assert_eq(
				definition.get_category(), str(category),
				"%s was filed under %s" % [definition.value, category]
			)


func test_irc_scopes_are_grouped_under_irc() -> void:
	var grouped := TwitchScope.get_grouped_scopes()
	assert_has(grouped, "IRC", "the two IRC scopes carry an explicit category")

#endregion


#region sort_scopes

func test_sort_scopes_is_deterministic() -> void:
	var first := TwitchScope.get_all_scopes()
	var second := TwitchScope.get_all_scopes()
	first.sort_custom(TwitchScope.sort_scopes)
	second.sort_custom(TwitchScope.sort_scopes)

	var first_values: PackedStringArray = []
	var second_values: PackedStringArray = []
	for definition: TwitchScope.Definition in first:
		first_values.append(String(definition.value))
	for definition: TwitchScope.Definition in second:
		second_values.append(String(definition.value))

	assert_eq(first_values, second_values, "sorting the same input twice must give the same order")

#endregion
