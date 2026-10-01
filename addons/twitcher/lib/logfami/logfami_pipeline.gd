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
## Configure the filter and the processors before the first record; a pipeline
## in use may be read from several threads at once. Serialization of the
## output is the sink's job, see [LogfamiSink].

var formatter: LogfamiFormatter
var sink: LogfamiSink
## Lowest severity this pipeline accepts.
var min_level: int
## When not empty, only these scopes pass.
var include_scopes: PackedStringArray = []
## These scopes never pass.
var exclude_scopes: PackedStringArray = []
## Replaced as a whole by [method add_processor], never changed in place.
var processors: Array[LogfamiProcessor] = []


func _init(pipeline_formatter: LogfamiFormatter, pipeline_sink: LogfamiSink,
		level: int = LogfamiLevel.Severity.INFO) -> void:
	formatter = pipeline_formatter
	sink = pipeline_sink
	min_level = level
	sink.configure(formatter)


## Appends [param processor]; processors run in the order they were added.
func add_processor(processor: LogfamiProcessor) -> LogfamiPipeline:
	var extended: Array[LogfamiProcessor] = processors.duplicate()
	extended.append(processor)
	processors = extended
	return self


func accepts(scope: String, level: int) -> bool:
	if level < min_level:
		return false
	if exclude_scopes.has(scope):
		return false
	return include_scopes.is_empty() or include_scopes.has(scope)


## Hands the formatter's session header to the sink.
func start(resource: LogfamiResource, started_unix_ms: int) -> void:
	sink.start_session(formatter.header(resource, started_unix_ms))


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
	sink.write(formatter.format(processed, resource), processed)


func flush() -> void:
	sink.flush()


func close() -> void:
	sink.close()
