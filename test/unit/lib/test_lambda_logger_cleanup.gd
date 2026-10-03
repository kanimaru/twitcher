extends TwitcherTest
## Unit tests for [LambdaLoggerCleanup] and the libraries using it.
##
## Godot frees a lambda with its script before the static variables of other
## scripts at shutdown; a lambda still kept in a static logger dictionary then
## crashes the game on quit.


class MethodLogger:
	extends RefCounted

	func write(_text: String) -> void:
		pass


## Every library class keeping its loggers in a static dictionary.
var _logger_classes: Array[GDScript] = [
	BufferedHTTPClient,
	HTTPServer,
	WebsocketClient,
	OAuth,
	OAuthTokenHandler,
	OAuthToken,
]
var _method_logger: MethodLogger
var _lambda: Callable


func before_each() -> void:
	super()
	_method_logger = MethodLogger.new()
	_lambda = func(_text: String) -> void:
		pass


func test_remove_lambdas_keeps_methods() -> void:
	var logger: Dictionary = {
		error = _lambda,
		info = _method_logger.write,
		debug = _lambda,
	}

	LambdaLoggerCleanup.remove_lambdas(logger)

	assert_eq(logger.keys(), [&"info"], "lambdas must go before shutdown, methods stay")


func test_has_lambda() -> void:
	assert_true(LambdaLoggerCleanup.has_lambda([_method_logger.write, _lambda]))
	assert_false(LambdaLoggerCleanup.has_lambda([_method_logger.write, _method_logger.write]))


func test_remove_on_shutdown_connects_once() -> void:
	var remover: Callable = BufferedHTTPClient._remove_lambda_loggers

	LambdaLoggerCleanup.remove_on_shutdown(remover)
	LambdaLoggerCleanup.remove_on_shutdown(remover)

	assert_true(get_tree().root.tree_exiting.is_connected(remover))


func test_libraries_remove_lambda_loggers() -> void:
	for logger_class: GDScript in _logger_classes:
		logger_class.call(&"set_logger", _lambda, _method_logger.write, _lambda)

		logger_class.call(&"_remove_lambda_loggers")

		var logger: Dictionary = logger_class.get(&"logger")
		assert_eq(logger.keys(), [&"info"], "%s keeps only the method" % logger_class.get_global_name())


func test_libraries_watch_the_tree_shutdown_for_lambdas() -> void:
	for logger_class: GDScript in _logger_classes:
		logger_class.call(&"set_logger", _lambda, _lambda, _lambda)

		var remover: Callable = Callable(logger_class, &"_remove_lambda_loggers")
		assert_true(get_tree().root.tree_exiting.is_connected(remover),
				"%s removes its lambdas on shutdown" % logger_class.get_global_name())


func test_http_util_cascade_removes_lambda_loggers() -> void:
	var http_util: GDScript = preload("res://addons/twitcher/lib/http/http_util.gd")
	http_util.call(&"set_logger", _lambda, _method_logger.write, _lambda)

	for logger_class: GDScript in [BufferedHTTPClient, HTTPServer, WebsocketClient]:
		logger_class.call(&"_remove_lambda_loggers")
		var logger: Dictionary = logger_class.get(&"logger")
		assert_eq(logger.keys(), [&"info"], "%s keeps only the method" % logger_class.get_global_name())
