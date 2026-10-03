class_name LambdaLoggerCleanup
extends Object
## Removes lambda loggers before Godot frees them at shutdown.
##
## Godot frees a lambda together with the script that defines it. At shutdown
## that happens before the static variables of other scripts are cleared, so a
## lambda still kept in a static [code]logger[/code] dictionary crashes the game
## on quit. Bound methods are not affected.
##
## Usage from a class with a static [code]logger[/code] dictionary:
## [codeblock]
## static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
##     logger.debug = debug
##     logger.info = info
##     logger.error = error
##     if LambdaLoggerCleanup.has_lambda([error, info, debug]):
##         LambdaLoggerCleanup.remove_on_shutdown(MyClass._remove_lambda_loggers)
##
## static func _remove_lambda_loggers() -> void:
##     LambdaLoggerCleanup.remove_lambdas(logger)
## [/codeblock]


## True when one of [param callables] is a lambda (or another custom callable).
static func has_lambda(callables: Array[Callable]) -> bool:
	for callable: Callable in callables:
		if callable.is_custom():
			return true
	return false


## Calls [param remover] once the scene tree's root leaves the tree:
## after every node logged its last lines, before Godot frees the scripts.
## Registering the same callable twice connects it once.
static func remove_on_shutdown(remover: Callable) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop == null:
		# A SceneTree script's _init runs before it becomes the main loop.
		LambdaLoggerCleanup.remove_on_shutdown.call_deferred(remover)
		return
	var tree: SceneTree = main_loop as SceneTree
	if tree == null or tree.root == null:
		return
	if not tree.root.tree_exiting.is_connected(remover):
		tree.root.tree_exiting.connect(remover)


## Erases every lambda (or other custom callable) from [param logger].
static func remove_lambdas(logger: Dictionary) -> void:
	for key: Variant in logger.keys():
		var callable: Callable = logger[key]
		if callable.is_custom():
			logger.erase(key)
