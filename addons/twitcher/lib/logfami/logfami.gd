@tool
class_name Logfami
extends RefCounted
## Standalone structured logger: records go through one or more pipelines,
## each with its own filter, processors, format and destination.
##
## Logfami doesn't depend on any other addon. It accepts records from three
## kinds of sources:
## [codeblock]
## var logfami: Logfami = Logfami.new()
## logfami.add_pipeline(LogfamiPipeline.new(LogfamiTextFormatter.new(), sink))
##
## logfami.log_message(LogfamiLevel.Severity.INFO, "Shop", "Item bought", { "id": 42 })
## some_manager.add_handler(logfami.as_handler())   # record dictionaries
## SomeLib.set_logger.callv(logfami.as_triple("SomeLib"))  # error, info, debug
## [/codeblock]

var resource: LogfamiResource
var clock: LogfamiClock

var _pipelines: Array[LogfamiPipeline] = []
var _mutex: Mutex = Mutex.new()
## Threads currently writing, to drop records produced while writing one
## (e.g. a sink warning that is captured again).
var _writing_threads: Dictionary[int, bool] = {}


func _init(log_resource: LogfamiResource = null, log_clock: LogfamiClock = null) -> void:
	resource = log_resource if log_resource != null else LogfamiResource.detect()
	clock = log_clock if log_clock != null else LogfamiClock.new()


## Adds [param pipeline] and starts its session right away.
func add_pipeline(pipeline: LogfamiPipeline) -> Logfami:
	pipeline.start(resource, clock.now_unix_ms())
	_mutex.lock()
	var pipelines: Array[LogfamiPipeline] = _pipelines.duplicate()
	pipelines.append(pipeline)
	_pipelines = pipelines
	_mutex.unlock()
	return self


func remove_pipeline(pipeline: LogfamiPipeline) -> void:
	_mutex.lock()
	var pipelines: Array[LogfamiPipeline] = _pipelines.duplicate()
	pipelines.erase(pipeline)
	_pipelines = pipelines
	_mutex.unlock()


func get_pipelines() -> Array[LogfamiPipeline]:
	return _pipelines.duplicate()


## Lowest severity any pipeline accepts, [constant LogfamiLevel.OFF] without
## pipelines. Use it when subscribing Logfami to another system.
func min_level() -> int:
	var lowest: int = LogfamiLevel.OFF
	for pipeline: LogfamiPipeline in _pipelines:
		lowest = mini(lowest, pipeline.min_level)
	return lowest


## True when any pipeline accepts [param level] records of [param scope].
func wants(scope: String, level: int) -> bool:
	for pipeline: LogfamiPipeline in _pipelines:
		if pipeline.accepts(scope, level):
			return true
	return false


func log_message(level: int, scope: String, body: String, attributes: Dictionary = {}) -> void:
	if not wants(scope, level):
		return
	log_record(LogfamiRecord.create(level, scope, body, attributes, clock))


## Logs a record in dictionary form, see [method LogfamiRecord.from_dict].
func log_dict(data: Dictionary) -> void:
	log_record(LogfamiRecord.from_dict(data))


func log_record(record: LogfamiRecord) -> void:
	var thread_id: int = OS.get_thread_caller_id()
	if not _enter_write(thread_id):
		return
	for pipeline: LogfamiPipeline in _pipelines:
		pipeline.emit(record, resource)
	_leave_write(thread_id)


## [code]func(record: Dictionary) -> void[/code] for systems that hand over
## record dictionaries.
func as_handler() -> Callable:
	return log_dict


## [code][error, info, debug][/code] callables taking one [String], for
## libraries with a [code]set_logger(error, info, debug)[/code] convention.
func as_triple(scope: String) -> Array[Callable]:
	return [
		_log_text.bind(LogfamiLevel.Severity.ERROR, scope),
		_log_text.bind(LogfamiLevel.Severity.INFO, scope),
		_log_text.bind(LogfamiLevel.Severity.DEBUG, scope),
	]


func flush() -> void:
	for pipeline: LogfamiPipeline in _pipelines:
		pipeline.flush()


func close() -> void:
	for pipeline: LogfamiPipeline in _pipelines:
		pipeline.close()


func _log_text(text: String, level: int, scope: String) -> void:
	log_message(level, scope, text)


func _enter_write(thread_id: int) -> bool:
	_mutex.lock()
	var is_nested: bool = _writing_threads.has(thread_id)
	if not is_nested:
		_writing_threads[thread_id] = true
	_mutex.unlock()
	return not is_nested


func _leave_write(thread_id: int) -> void:
	_mutex.lock()
	_writing_threads.erase(thread_id)
	_mutex.unlock()
