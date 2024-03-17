extends Node

# Handles multiple hosts.
# Handles parralel requests.
# Stopping Clients after X Seconds with no additional request.

## This one get send when the http client gets closed to cleanup stuff
signal client_closed(http_client: BufferedHTTPClient);
## Got send when a new client got added
signal client_added(http_client: BufferedHTTPClient);

## Time between the checks to cleanup unused http clients
const CLEANUP_TIME_IN_SEC = 1;

var l: TwitchLogger = TwitchLogger.new(TwitchSetting.LOGGER_NAME_HTTP_CLIENT);

## Key: url | value: array of BufferedHTTPClient
var http_client_map: Dictionary;

func _ready() -> void:
	var cleanup_timer = Timer.new();
	cleanup_timer.autostart = true;
	cleanup_timer.wait_time = CLEANUP_TIME_IN_SEC;
	cleanup_timer.timeout.connect(_cleanup);
	add_child(cleanup_timer);

func _get_host_key(host: String, port: int):
	return host + ":" + str(port);

func _get_or_create_client(host: String, port: int = -1) -> BufferedHTTPClient:
	var host_key = _get_host_key(host, port);
	if http_client_map.has(host_key):
		var clients : Array[BufferedHTTPClient] = http_client_map[host_key];
		if clients.size() + 1 >= TwitchSetting.http_client_max:
			return clients.pick_random();
		var client: BufferedHTTPClient = BufferedHTTPClient.new(host, port);
		clients.append(client);
		client_added.emit(client);
		l.i("Client for %s got added" % host)
		return client;
	else:
		var typed_array: Array[BufferedHTTPClient] = []
		http_client_map[host_key] = typed_array;
		for i in range(TwitchSetting.http_client_min):
			var client: BufferedHTTPClient = BufferedHTTPClient.new(host, port);
			typed_array.append(client);
			client_added.emit(client);
			l.i("Client for %s got added" % host)
		return typed_array[0];

## Returns an free client, creates one when not available or picks random when the
## max amount of clients per host is reached.
func get_client(host: String, port: int = -1) -> BufferedHTTPClient:
	var host_key = _get_host_key(host, port);
	if not http_client_map.has(host_key):
		return _get_or_create_client(host, port);

	for client in http_client_map[host_key]:
		if client.is_free(): return client;

	return _get_or_create_client(host, port);

## Clenup unused clients
func _cleanup() -> void:
	for host in http_client_map:
		var clients = http_client_map[host];
		_cleanup_host(clients);

func _cleanup_host(clients: Array) -> void:
	var free_clients: Array = clients.filter(func(c): return c.queued_request_size() == 0);
	if free_clients.size() == 0: return;
	if clients.size() > TwitchSetting.http_client_min:
		var to_teardown = min(clients.size() - TwitchSetting.http_client_min, free_clients.size());
		for i in range(to_teardown):
			var client : BufferedHTTPClient = free_clients[i];
			client.shutdown();
			clients.erase(client);
			client_closed.emit(client);
