extends Control

@onready var clients: Tree = %Clients

## Key: url as String | value: TreeItem
var url_map : Dictionary = {};
## Key: BufferedHTTPClient | value: TreeItem
var client_map : Dictionary = {};
## Key: RequestData | value: TreeItem
var request_map : Dictionary = {};

func _ready() -> void:
	HttpClientManager.client_added.connect(_new_client);
	HttpClientManager.client_closed.connect(_close_client);
	for host in HttpClientManager.http_client_map:
		for client in HttpClientManager.http_client_map[host]:
			_new_client(client);

func _new_client(client: BufferedHTTPClient):
	var url = client.base_url;
	if not url_map.has(url):
		url_map[url] = _add_path(url);

	var parent: TreeItem = url_map[url];

	var http_item = clients.create_item(parent);
	http_item.set_text(0, "Client-%s" % client.index);
	client_map[client] = http_item;

	client.request_added.connect(_on_add_request.bind(http_item));
	client.request_started.connect(_on_start_request);
	client.request_done.connect(_on_done_request);

func _on_add_request(request: BufferedHTTPClient.RequestData, http_item: TreeItem):
	var request_item = clients.create_item(http_item);
	request_item.set_text(0, request.path);
	request_item.set_text(1, "Queued")
	request_map[request] = request_item;

func _on_start_request(request: BufferedHTTPClient.RequestData):
	var request_item = request_map[request] as TreeItem;
	request_item.set_text(1, "PROGRESSING")

func _on_done_request(response: BufferedHTTPClient.ResponseData):
	var request_item = request_map[response.request_data] as TreeItem;
	request_item.set_text(1, "DONE")
	await get_tree().create_timer(60).timeout;
	if request_item != null: request_item.free();

func _add_path(path: String) -> TreeItem:
	var item = clients.create_item();
	item.set_text(0, path);
	return item;

func _close_client(client: BufferedHTTPClient):
	var http_item = client_map[client] as TreeItem;
	client_map.erase(client);
	http_item.set_text(1, "CLOSED")
	await get_tree().create_timer(60).timeout;
	http_item.free();
