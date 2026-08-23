## Unit tests for [RegexUtil].
##
## [code]escape()[/code] is the single purest function in Twitcher: static, no
## dependencies, String in and String out. It is used by
## [code]TwitchCommandContains[/code] to build word-boundary patterns from
## user-supplied trigger words, so a miss here means a chat command silently
## fails to match — or worse, a user-supplied string is interpreted as a regex.
extends TwitcherTest

const Subject := preload("res://addons/twitcher/lib/regex/regex_util.gd")

## Every metacharacter the implementation claims to handle, as
## [code][raw, escaped][/code].
##
## Deliberately written out rather than generated, so that a metacharacter being
## dropped from the implementation shows up as a failing row rather than
## quietly shrinking the generated list too.
var metacharacter_params := [
	[".", "\\."],
	["^", "\\^"],
	["$", "\\$"],
	["*", "\\*"],
	["+", "\\+"],
	["?", "\\?"],
	["(", "\\("],
	[")", "\\)"],
	["[", "\\["],
	["]", "\\]"],
	["{", "\\{"],
	["}", "\\}"],
	["|", "\\|"],
	["\\", "\\\\"],
]

## Strings that contain no metacharacters and must survive untouched.
var passthrough_params := [
	"",
	"hello",
	"Hello World",
	"kappa123",
	"snake_case-and-dashes",
	"a/b/c",
	"ümläut",
	"日本語",
	"emote:1234",
]


func test_escapes_each_metacharacter(params = use_parameters(metacharacter_params)) -> void:
	var raw: String = params[0]
	var expected: String = params[1]
	assert_eq(Subject.escape(raw), expected, "escaping [%s]" % raw)


func test_leaves_non_metacharacters_untouched(params = use_parameters(passthrough_params)) -> void:
	assert_eq(Subject.escape(params), params, "passthrough of [%s]" % params)


## The implementation escapes backslash first and every other metacharacter
## afterwards. If that order were reversed, the backslashes introduced by the
## other rules would themselves be escaped, doubling them.
##
## This is the one ordering bug that would make [code]escape()[/code] produce
## a valid-but-wrong pattern rather than an outright invalid one, so it gets its
## own test rather than riding along in the round-trip below.
func test_backslash_is_escaped_before_other_metacharacters() -> void:
	assert_eq(Subject.escape("\\."), "\\\\\\.", "backslash-dot must not double-escape the dot's backslash")
	assert_eq(Subject.escape("a\\b.c"), "a\\\\b\\.c")


func test_escapes_every_metacharacter_in_one_string() -> void:
	assert_eq(
		Subject.escape(".^$*+?()[]{}|"),
		"\\.\\^\\$\\*\\+\\?\\(\\)\\[\\]\\{\\}\\|"
	)


func test_repeated_metacharacters_are_all_escaped() -> void:
	assert_eq(Subject.escape("..."), "\\.\\.\\.")
	assert_eq(Subject.escape("**"), "\\*\\*")


## The contract that actually matters: whatever comes out must compile, and must
## match the original string literally and nothing more.
func test_escaped_string_compiles_and_matches_itself_literally(
	params = use_parameters(metacharacter_params)
) -> void:
	var raw: String = params[0]
	var pattern := Subject.escape(raw)
	var regex := RegEx.create_from_string(pattern)

	assert_not_null(regex, "escape() produced an uncompilable pattern for [%s]" % raw)
	if regex == null:
		return

	var found := regex.search(raw)
	assert_not_null(found, "escaped [%s] did not match its own source" % raw)
	if found != null:
		assert_eq(found.get_string(), raw, "matched something other than the literal input")


## A realistic case: a chat trigger containing metacharacters, wrapped in word
## boundaries the way [code]TwitchCommandContains[/code] does it.
func test_word_boundary_wrapping_survives_escaping() -> void:
	var trigger := "a.b"
	var regex := RegEx.create_from_string("\\b%s\\b" % Subject.escape(trigger))
	assert_not_null(regex, "word-boundary pattern failed to compile")
	if regex == null:
		return
	assert_not_null(regex.search("say a.b please"), "should match the trigger in a sentence")
	assert_null(regex.search("say axb please"), "escaped dot must not act as a wildcard here")


## Pins a trap in [code]TwitchCommandContains[/code] rather than in
## [code]escape()[/code] itself.
##
## [code]escape()[/code] handles [code]c++[/code] correctly, but the
## [code]\b...\b[/code] wrapping that [code]match_word[/code] applies can never
## match it: [code]\b[/code] needs a word character on one side, and both
## [code]+[/code] and the following space are non-word. So a trigger ending in a
## metacharacter silently never fires when [code]match_word[/code] is enabled.
##
## Recorded here because the regex layer is where the surprise originates. When
## the [code]TwitchCommandContains[/code] suite lands it should either fix this
## (drop the boundary when the trigger's edge is non-word) or repeat the
## assertion as an accepted limitation.
func test_word_boundaries_cannot_match_a_trigger_ending_in_a_metacharacter() -> void:
	var pattern := "\\b%s\\b" % Subject.escape("c++")
	var regex := RegEx.create_from_string(pattern)
	assert_not_null(regex, "pattern must still compile")
	if regex == null:
		return
	assert_null(
		regex.search("i love c++ a lot"),
		"known limitation: \\b cannot anchor after '+' — see doc comment"
	)
	assert_not_null(
		RegEx.create_from_string(Subject.escape("c++")).search("i love c++ a lot"),
		"without the boundary wrapping the escaped trigger matches fine"
	)


## An unescaped metacharacter string would compile into something that matches
## far more than intended. This pins that escaping actually narrows the match.
func test_escaping_prevents_wildcard_behaviour() -> void:
	var unescaped := RegEx.create_from_string("a.c")
	var escaped := RegEx.create_from_string(Subject.escape("a.c"))

	assert_not_null(unescaped.search("abc"), "sanity: unescaped dot is a wildcard")
	assert_null(escaped.search("abc"), "escaped dot must not act as a wildcard")
	assert_not_null(escaped.search("a.c"), "escaped dot must still match a literal dot")


## Documents a deliberate gap rather than asserting a bug: [code]-[/code] and
## [code]/[/code] are not escaped. Both are only special inside character
## classes, which [code]escape()[/code] never produces, so this is safe — but it
## is worth pinning so that a future change to the escape table is a conscious
## decision.
func test_hyphen_and_slash_are_intentionally_not_escaped() -> void:
	assert_eq(Subject.escape("a-b"), "a-b", "hyphen is only special inside [] — see doc comment")
	assert_eq(Subject.escape("a/b"), "a/b", "forward slash is not special in Godot's RegEx")
