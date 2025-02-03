extends Control

@onready var clients: Tree = %Clients

## Key: BufferedHTTPClient | value: TreeItem
var client_map : Dictionary[BufferedHTTPClient, TreeItem] = {}
## Key: RequestData | value: TreeItem
var request_map : Dictionary[BufferedHTTPClient.RequestData, TreeItem] = {}


func _ready() -> void:
	get_tree().root.child_entered_tree.connect(_on_child_enter)
	_add_http_clients(get_tree().root)
	
	
func _add_http_clients(parent: Node) -> void:
	for child in parent.get_children():
		_on_child_enter(child)
		_add_http_clients(child)
		

func _on_child_enter(node: Node) -> void:
	if node is BufferedHTTPClient:
		_new_client(node)


func _new_client(client: BufferedHTTPClient):
	var parent = clients.create_item()
	parent.set_text(0, client.name)
	
	client_map[client] = parent

	client.request_added.connect(_on_add_request.bind(parent))
	client.request_done.connect(_on_done_request)
	for request in client.requests:
		_on_add_request(request, parent)


func _on_add_request(request: BufferedHTTPClient.RequestData, http_item: TreeItem):
	var request_item = clients.create_item(http_item)
	request_item.set_text(0, request.path)
	request_item.set_text(1, "Queued")
	request_map[request] = request_item


func _on_done_request(response: BufferedHTTPClient.ResponseData):
	var request_item = request_map[response.request_data] as TreeItem
	request_item.set_text(1, "DONE")
	await get_tree().create_timer(60).timeout
	if request_item != null: request_item.free()


func _close_client(client: BufferedHTTPClient):
	var http_item = client_map[client] as TreeItem
	client_map.erase(client)
	http_item.set_text(1, "CLOSED")
	await get_tree().create_timer(60).timeout
	http_item.free()
