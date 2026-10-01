extends RefCounted
## Records every Logfami formatter renders in the golden-file tests.
##
## Written in GDScript rather than JSON, because Godot's JSON parser turns every
## number into a float and would change the expected output. Each record covers
## an edge case: an instance attribute, an injected line break, quotes and
## equal signs, unicode with nested attributes, and an empty record.

const STARTED_UNIX_MS: int = 1_759_139_999_000


static func resource() -> LogfamiResource:
	return LogfamiResource.new({
		"service.name": "Golden",
		"service.version": "1.2.0",
		"godot.version": "4.7.stable",
		"os.type": "linux",
		"process.pid": 1234,
		"runtime": "game",
	})


static func records() -> Array[LogfamiRecord]:
	return [
		_record(1_759_140_000_123, LogfamiLevel.Severity.INFO, "Auth",
				"Token got authorized", { "instance": "main", "expires_in": 3600 }),
		_record(1_759_140_001_000, LogfamiLevel.Severity.WARN, "Chat",
				"Fake line\n2025-09-29T10:00:00.000Z ERROR [Auth] forged", {}),
		_record(1_759_140_002_005, LogfamiLevel.Severity.ERROR, "IRC",
				"Connection lost", { "reason": "say \"bye\" = gone", "code": 4000 }),
		_record(1_759_140_003_050, LogfamiLevel.Severity.DEBUG, "Shop",
				"Unicode ✓ 日本語 Kappa", { "nested": { "b": 2, "a": 1 } }),
		_record(1_759_140_004_000, LogfamiLevel.Severity.FATAL, "", "", {}),
	]


## Header lines followed by one line per record, as a file would contain them.
static func render(formatter: LogfamiFormatter) -> PackedStringArray:
	var lines: PackedStringArray = formatter.header(resource(), STARTED_UNIX_MS)
	for record: LogfamiRecord in records():
		lines.append(formatter.format(record, resource()))
	return lines


static func _record(unix_ms: int, level: int, scope: String, body: String,
		attributes: Dictionary) -> LogfamiRecord:
	return LogfamiRecord.create(level, scope, body, attributes, LogfamiFixedClock.new(unix_ms))
