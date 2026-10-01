extends TwitcherTest
## Unit tests for [LogfamiTime].

var rfc3339_params: Array = [
	[0, "1970-01-01T00:00:00.000Z"],
	[1_759_140_000_123, "2025-09-29T10:00:00.123Z"],
	[1_759_140_002_005, "2025-09-29T10:00:02.005Z"],
	[1_759_140_000_999, "2025-09-29T10:00:00.999Z"],
	[951_825_600_000, "2000-02-29T12:00:00.000Z"],
]


func test_rfc3339(params: Array = use_parameters(rfc3339_params)) -> void:
	var unix_ms: int = params[0]
	var expected: String = params[1]
	assert_eq(LogfamiTime.rfc3339(unix_ms), expected)
