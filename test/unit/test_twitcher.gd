extends TwitcherTest
## Unit tests for [Twitcher].


## The version is duplicated in code because exported games don't ship
## plugin.cfg. This catches a release that bumps only one of them.
func test_version_matches_plugin_cfg() -> void:
	var config: ConfigFile = ConfigFile.new()
	assert_eq(config.load("res://addons/twitcher/plugin.cfg"), OK)
	assert_eq(Twitcher.VERSION, str(config.get_value("plugin", "version", "")))
