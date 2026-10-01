@tool
class_name LogfamiPipeline
extends RefCounted
## Filter → processors → formatter → sink, for one destination.
##
## [codeblock]
## var pipeline: LogfamiPipeline = LogfamiPipeline.new(
##         LogfamiTextFormatter.new(), LogfamiMemorySink.new(), LogfamiLevel.Severity.INFO)
## pipeline.add_processor(LogfamiRedactor.with_defaults())
## [/codeblock]

var formatter: LogfamiFormatter
var sink: LogfamiSink
## Lowest severity this pipeline accepts.
var min_level: int
## When not empty, only these scopes pass.
var include_scopes: PackedStringArray = []
## These scopes never pass.
var exclude_scopes: PackedStringArray = []
var processors: Array[LogfamiProcessor] = []

var _mutex: Mutex = Mutex.new()


func _init(pipeline_formatter: LogfamiFormatter, pipeline_sink: LogfamiSink,
		level: int = LogfamiLevel.Severity.INFO) -> void:
	formatter = pipeline_formatter
	sink = pipeline_sink
	min_level = level
	sink.configure(formatter)


## Appends [param processor]; processors run in the order they were added.
func add_processor(processor: LogfamiProcessor) -> LogfamiPipeline:
	processors.append(processor)
	return self


func accepts(scope: String, level: int) -> bool:
	if level < min_level:
		return false
	if exclude_scopes.has(scope):
		return false
	return include_scopes.is_empty() or include_scopes.has(scope)


## Hands the formatter's session header to the sink.
func start(resource: LogfamiResource, started_unix_ms: int) -> void:
	_mutex.lock()
	sink.start_session(formatter.header(resource, started_unix_ms))
	_mutex.unlock()


## Filters, processes, formats and writes [param record]. The record itself is
## never changed; processors work on a copy.
func emit(record: LogfamiRecord, resource: LogfamiResource) -> void:
	if not accepts(record.scope, record.severity_number):
		return
	var processed: LogfamiRecord = record.copy()
	for processor: LogfamiProcessor in processors:
		processed = processor.process(processed)
		if processed == null:
			return
	var line: String = formatter.format(processed, resource)
	_mutex.lock()
	sink.write(line, processed)
	_mutex.unlock()


func flush() -> void:
	_mutex.lock()
	sink.flush()
	_mutex.unlock()


func close() -> void:
	_mutex.lock()
	sink.close()
	_mutex.unlock()
