extends Object

## Parses a query string and returns a dictionary with the parameters.
static func parse_query(query: String) -> Dictionary:
	var parameters = Dictionary()
	# Split the query by '&' to separate different parameters.
	var pairs = query.split("&")
	# Iterate over each pair of key-value.
	for pair in pairs:
		# Split the pair by '=' to separate the key from the value.
		var kv = pair.split("=")
		if kv.size() == 2:
			var key = kv[0].strip_edges()
			var value = kv[1].strip_edges()
			var decoded_key = key.uri_decode()
			var decoded_value = value.uri_decode()
			parameters[decoded_key] = decoded_value
	return parameters


## Method to set all logger within this package
static func set_logger(error: Callable, info: Callable, debug: Callable) -> void:
	BufferedHTTPClient.set_logger(error, info, debug)
	HTTPServer.set_logger(error, info, debug)
	WebsocketClient.set_logger(error, info, debug)
