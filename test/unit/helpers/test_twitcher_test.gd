## Tests for the pause helpers of [TwitcherTest].
##
## A mistake here pauses the whole GUT run, so these pin that the test keeps
## running and that the pause is undone again.
extends TwitcherTest


func test_the_pausable_root_pauses_with_the_tree() -> void:
	var root: Node = add_pausable_root()

	get_tree().paused = true

	assert_false(root.can_process(), "the root has to stop like a game")
	assert_true(can_process(), "the test itself has to keep running")


func test_awaiting_works_while_the_tree_is_paused() -> void:
	add_pausable_root()
	get_tree().paused = true

	await wait_process_frames(2)

	pass_test("awaiting a paused tree has to end")


func test_restoring_unpauses_and_resets_the_process_mode() -> void:
	var before: Node.ProcessMode = process_mode
	add_pausable_root()
	get_tree().paused = true

	_restore_pause()

	assert_false(get_tree().paused)
	assert_eq(process_mode, before)


func test_several_roots_keep_the_original_process_mode() -> void:
	var before: Node.ProcessMode = process_mode
	add_pausable_root()
	add_pausable_root()

	_restore_pause()

	assert_eq(process_mode, before, "the second call must not remember ALWAYS as original")
