## Meta-tests for [StaticStateGuard].
##
## The guard is the load-bearing piece of the harness: if it silently stops
## restoring something, suites start contaminating one another and the resulting
## failures are order-dependent and miserable to diagnose. So the guard gets its
## own tests.
##
## Note that these deliberately do NOT call [code]super()[/code] in
## [method before_each] — they drive their own guard instances rather than the
## one [TwitcherTest] installs, so that a bug in the guard cannot mask itself.
extends TwitcherTest

const CommandBase := preload("res://addons/twitcher/chat/twitch_command_base.gd")
const HttpServer := preload("res://addons/twitcher/lib/http/http_server.gd")
const BufferedClient := preload("res://addons/twitcher/lib/http/buffered_http_client.gd")
const LoggerManager := preload("res://addons/twitcher/logger/twitch_logger_manager.gd")


func test_restores_a_mutated_static_array() -> void:
	var guard := StaticStateGuard.new()
	var original_size := CommandBase.ALL_COMMANDS.size()
	var probe := autofree(TwitchCommand.new()) as TwitchCommandBase

	guard.snapshot()
	CommandBase.ALL_COMMANDS.append(probe)
	assert_eq(
		CommandBase.ALL_COMMANDS.size(), original_size + 1,
		"sanity: the mutation must actually land"
	)

	guard.restore()
	assert_eq(
		CommandBase.ALL_COMMANDS.size(), original_size,
		"guard must undo appends to a static registry"
	)


## The snapshot has to be a copy. If the guard stored a live reference, restoring
## would assign the mutated container back over itself and quietly do nothing —
## the exact failure mode this test exists to catch.
func test_snapshot_of_a_container_is_a_copy_not_a_reference() -> void:
	var guard := StaticStateGuard.new()
	LoggerManager.log_registry = {"a": 1, "b": 2}

	guard.snapshot()
	LoggerManager.log_registry.clear()
	guard.restore()

	assert_eq(
		LoggerManager.log_registry, {"a": 1, "b": 2},
		"restore after an in-place clear proves the snapshot was deep"
	)


func test_restores_a_reassigned_static_dictionary() -> void:
	var guard := StaticStateGuard.new()
	guard.snapshot()

	HttpServer._servers = {9999: "contamination"}
	guard.restore()

	assert_false(
		HttpServer._servers.has(9999),
		"guard must undo a wholesale reassignment of the port registry"
	)


## [code]TwitchAuth._init()[/code] rewrites the logger callables on three
## unrelated classes as a side effect of construction. This is the single
## nastiest leak in the codebase, so it gets an explicit test.
func test_restores_static_logger_callables() -> void:
	var guard := StaticStateGuard.new()
	var original: Variant = BufferedClient.logger

	guard.snapshot()
	BufferedClient.logger = {"contaminated": true}
	guard.restore()

	assert_eq(
		BufferedClient.logger, original,
		"guard must restore the logger cascade's static state"
	)


func test_restores_project_settings_under_the_twitcher_prefix() -> void:
	var guard := StaticStateGuard.new()
	var key := "twitcher/logs/GutGuardProbe"
	ProjectSettings.set_setting(key, "off")

	guard.snapshot()
	ProjectSettings.set_setting(key, "debug")
	guard.restore()

	assert_eq(
		ProjectSettings.get_setting(key), "off",
		"logger construction writes ProjectSettings; the guard must undo it"
	)
	ProjectSettings.clear(key)


## An aborted test could leave a guard that was constructed but never snapshotted.
## Restoring from that state must be a no-op rather than writing nulls over live
## state.
func test_restore_without_snapshot_is_a_no_op() -> void:
	var guard := StaticStateGuard.new()
	LoggerManager.log_registry = {"untouched": true}

	guard.restore()

	assert_eq(
		LoggerManager.log_registry, {"untouched": true},
		"restore before snapshot must not clobber anything"
	)


func test_snapshot_can_be_taken_repeatedly() -> void:
	var guard := StaticStateGuard.new()
	guard.snapshot()
	LoggerManager.log_registry = {"first": true}
	guard.snapshot()
	LoggerManager.log_registry = {"second": true}
	guard.restore()

	assert_eq(
		LoggerManager.log_registry, {"first": true},
		"the most recent snapshot must win"
	)


## Guards against silent decay: if a path in the slot table is renamed by a
## refactor, [method StaticStateGuard._load] skips it and the guard quietly stops
## protecting that slot. This asserts every declared slot actually resolved.
func test_every_declared_slot_resolves_to_a_real_script() -> void:
	var guard := StaticStateGuard.new()
	guard.snapshot()

	assert_eq(
		guard.tracked_slots().size(), StaticStateGuard._SLOTS.size(),
		"a slot failed to load — its script path is probably stale"
	)


func test_slot_table_has_no_duplicate_entries() -> void:
	var seen: Dictionary[String, bool] = {}
	var duplicates: PackedStringArray = []
	for slot: Dictionary in StaticStateGuard._SLOTS:
		var id := "%s::%s" % [slot["path"], slot["prop"]]
		if seen.has(id):
			duplicates.append(id)
		seen[id] = true
	assert_eq(duplicates.size(), 0, "duplicate slots: " + ", ".join(duplicates))
