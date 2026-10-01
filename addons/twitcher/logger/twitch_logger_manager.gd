@tool
class_name TwitchLoggerManager
extends RefCounted
## Couples the loggers to the project settings and dispatches their records to
## the registered handlers.
##
## A handler is any [code]func(record: Dictionary) -> void[/code]; the record
## shape is documented in [TwitchLogRecord]. Handlers don't need to know any
## Twitcher class, so an external logging solution can subscribe with a plain
## [Callable]:
## [codeblock]
## TwitchLoggerManager.add_handler(my_logger.write, TwitchLogLevel.Severity.INFO)
## [/codeblock]
## The console output is a handler too ([TwitchConsoleLogHandler]). It's
## installed on load and can be removed with [method remove_handler] or
## [method clear_handlers]. The log file ([TwitchLogfamiBridge]) is installed
## on the first log call, so it can still be switched off from an autoload.
##
## Handlers are called on the thread that logged. The handler list is replaced
## as a whole on every change (copy on write), so logging never waits for a
## lock unless a record is actually dispatched.
##
## Lambda handlers are removed when the scene tree shuts down. Godot frees a
## lambda together with its script, before static variables like this
## registry; a lambda still registered at that point crashes the game on quit.
## Methods, bound or not, are unaffected and stay registered. A lambda whose
## name equals a method of the object it was created in is mistaken for a bound
## method and stays too; give such lambdas another name.

## Context name to the [TwitchLogger] registered last under that name.
static var log_registry: Dictionary = {}

static var _handlers: Array[TwitchLogHandlerEntry] = []
static var _console: TwitchConsoleLogHandler
static var _mutex: Mutex = Mutex.new()
## Threads currently inside [method dispatch], to drop records a handler logs
## while handling another record.
static var _dispatching_threads: Dictionary[int, bool] = {}
## True while a deferred retry of [method _watch_shutdown] is queued.
static var _is_shutdown_watch_deferred: bool = false


static func _static_init() -> void:
	install_console_handler()


## Registers the logger and sets the enabled state from its project setting.
static func register(logger: TwitchLogger) -> void:
	log_registry[logger.context_name] = logger
	var key: String = "twitcher/logs/%s" % logger.context_name
	var property: TwitchProperty = TwitchProperty.new(key, "off")
	property.as_select(["off", "info", "debug"])
	if property.get_val() != "off":
		logger.set_enabled(true)
	if property.get_val() == "debug":
		logger.debug = true


## Adds [param handler] for every scope, receiving records at [param min_level]
## and above. Adding a handler twice replaces its previous registration.
static func add_handler(handler: Callable,
		min_level: int = TwitchLogLevel.Severity.INFO) -> void:
	_add_entry(TwitchLogHandlerEntry.new(handler, min_level))


## Adds [param handler] with a threshold per scope, looked up by
## [param level_resolver] whenever a record is about to be created:
## [code]func(scope: String, logger: TwitchLogger) -> int[/code], where
## [code]logger[/code] is the emitting logger or [code]null[/code] for records
## dispatched directly.
static func add_scoped_handler(handler: Callable, level_resolver: Callable) -> void:
	_add_entry(TwitchLogHandlerEntry.new(handler, TwitchLogLevel.OFF, level_resolver))


static func remove_handler(handler: Callable) -> void:
	_mutex.lock()
	_handlers = _without(_handlers, handler)
	_mutex.unlock()


static func has_handler(handler: Callable) -> bool:
	var handlers: Array[TwitchLogHandlerEntry] = _handlers
	for entry: TwitchLogHandlerEntry in handlers:
		if entry.handler == handler:
			return true
	return false


static func handler_count() -> int:
	return _handlers.size()


## Removes every handler, the console included. Use
## [method install_console_handler] to bring the console back.
static func clear_handlers() -> void:
	_mutex.lock()
	_handlers = []
	_mutex.unlock()


## Removes every handler and resolver that is a lambda. Called automatically
## when the scene tree shuts down; call it yourself before [method SceneTree.quit]
## in a [code]-s[/code] script that registered lambdas.
static func remove_lambda_handlers() -> void:
	_mutex.lock()
	var remaining: Array[TwitchLogHandlerEntry] = []
	for entry: TwitchLogHandlerEntry in _handlers:
		if not entry.has_lambda():
			remaining.append(entry)
	_handlers = remaining
	_mutex.unlock()


## Adds the console handler unless it's already installed.
static func install_console_handler() -> void:
	var console: TwitchConsoleLogHandler = get_console_handler()
	if not has_handler(console.handle):
		add_scoped_handler(console.handle, console.threshold_for)


static func get_console_handler() -> TwitchConsoleLogHandler:
	if _console == null:
		_console = TwitchConsoleLogHandler.new()
	return _console


## True when at least one handler wants [param level] records of [param scope].
## Loggers call this before they build a record, which keeps disabled log calls
## cheap. [param logger] is the emitting logger, for per-instance thresholds.
static func wants(scope: String, level: int, logger: TwitchLogger = null) -> bool:
	TwitchLogfamiBridge.install_once()
	var handlers: Array[TwitchLogHandlerEntry] = _handlers
	for entry: TwitchLogHandlerEntry in handlers:
		if entry.accepts(scope, level, logger):
			return true
	return false


## Hands [param record] to every handler that accepts its scope and level.
## Records logged by a handler while it handles a record are dropped.
static func dispatch(record: Dictionary, logger: TwitchLogger = null) -> void:
	TwitchLogfamiBridge.install_once()
	var thread_id: int = OS.get_thread_caller_id()
	if not _enter_dispatch(thread_id):
		return
	var scope: String = record.get(TwitchLogRecord.SCOPE, "")
	var level: int = record.get(TwitchLogRecord.SEVERITY_NUMBER, TwitchLogLevel.Severity.INFO)
	var handlers: Array[TwitchLogHandlerEntry] = _handlers
	var has_stale_entries: bool = false
	for entry: TwitchLogHandlerEntry in handlers:
		if not entry.is_valid():
			has_stale_entries = true
		elif entry.accepts(scope, level, logger):
			entry.handler.call(record)
	_leave_dispatch(thread_id)
	if has_stale_entries:
		_remove_stale_entries()


static func _add_entry(entry: TwitchLogHandlerEntry) -> void:
	_mutex.lock()
	var handlers: Array[TwitchLogHandlerEntry] = _without(_handlers, entry.handler)
	handlers.append(entry)
	_handlers = handlers
	_mutex.unlock()
	if entry.has_lambda():
		_watch_shutdown()


## Connects [method remove_lambda_handlers] to the scene tree's root leaving
## the tree: after every node logged its last lines, before Godot frees the
## scripts. During a [code]-s[/code] script's [code]_init[/code] there is no
## main loop yet, so the connection is retried once the loop is up.
static func _watch_shutdown() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		if not _is_shutdown_watch_deferred:
			_is_shutdown_watch_deferred = true
			Callable(TwitchLoggerManager, &"_watch_shutdown_deferred").call_deferred()
		return
	var remove_lambdas: Callable = Callable(TwitchLoggerManager, &"remove_lambda_handlers")
	if not tree.root.tree_exiting.is_connected(remove_lambdas):
		tree.root.tree_exiting.connect(remove_lambdas)


static func _watch_shutdown_deferred() -> void:
	_is_shutdown_watch_deferred = false
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		_watch_shutdown()


static func _remove_stale_entries() -> void:
	_mutex.lock()
	var remaining: Array[TwitchLogHandlerEntry] = []
	for entry: TwitchLogHandlerEntry in _handlers:
		if entry.is_valid():
			remaining.append(entry)
	_handlers = remaining
	_mutex.unlock()


static func _without(handlers: Array[TwitchLogHandlerEntry],
		handler: Callable) -> Array[TwitchLogHandlerEntry]:
	var remaining: Array[TwitchLogHandlerEntry] = []
	for entry: TwitchLogHandlerEntry in handlers:
		if entry.handler != handler:
			remaining.append(entry)
	return remaining


static func _enter_dispatch(thread_id: int) -> bool:
	_mutex.lock()
	var is_nested: bool = _dispatching_threads.has(thread_id)
	if not is_nested:
		_dispatching_threads[thread_id] = true
	_mutex.unlock()
	return not is_nested


static func _leave_dispatch(thread_id: int) -> void:
	_mutex.lock()
	_dispatching_threads.erase(thread_id)
	_mutex.unlock()
