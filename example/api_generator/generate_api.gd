extends Control

@onready var twitch_api_generator: TwitchAPIGenerator = %TwitchAPIGenerator
@onready var twitch_api_parser: TwitchAPIParser = %TwitchAPIParser
@onready var methods_tree: Tree = %Methods
@onready var components_tree: Tree = %Components
@onready var show: Button = %Show
@onready var component_search: LineEdit = %ComponentSearch
@onready var method_search: LineEdit = %MethodSearch

@onready var generate: Button = %Generate
#@onready var twitch_api: TwitchAPI = %TwitchAPI
@onready var request: Button = %Request
#@onready var twitch_auth: TwitchAuth = $TwitchAuth

var ref_item_map : Dictionary[String, TreeItem] = {}
var method_item_map : Dictionary[String, TreeItem] = {}


func _ready() -> void:
	generate.pressed.connect(_on_generate)
	request.pressed.connect(_on_request)
	show.pressed.connect(_show_api)
	component_search.text_submitted.connect(_on_search_component)
	method_search.text_submitted.connect(_on_search_method)
	await twitch_api_parser.parse_api()
	#twitch_auth.authorize()

	
func _on_request() -> void:
	#var opt: TwitchAPI.TwitchGetClipsOpt = TwitchAPI.TwitchGetClipsOpt.new()
	#opt.broadcaster_id = twitch_api.broadcaster_user.id
	#var streams: TwitchGetClipsResponse = await twitch_api.get_clips(opt)
	#for stream_promise in streams:
		#var stream = await stream_promise
		#print(stream.title)
	pass
			
	
func _on_generate() -> void:
	twitch_api_generator.generate_api()
	pass
	

func _show_api() -> void:
	var root_method = methods_tree.create_item()
	for method in twitch_api_parser.methods:
		var method_row: TreeItem = methods_tree.create_item(root_method)
		method_item_map[method._name] = method_row
		method_row.set_text(0, method._name)
		method_row.set_text(1, method._result_type)
		
		for parameter in method._parameters:
			var parameter_row: TreeItem = methods_tree.create_item(method_row)
			parameter_row.set_text(0, parameter._name)
			parameter_row.set_text(1, parameter._type)
			var mods = ""
			mods += "R" if parameter._required else "O"
			mods += "A" if parameter._is_array else "-"
			parameter_row.set_text(2, mods)
			
	var root_component = components_tree.create_item()
	var groups = twitch_api_generator.grouped_files
	for file in groups:
		var file_row: TreeItem = components_tree.create_item(root_component)
		file_row.set_text(0, file)
		
		var comp_or_group: Variant = groups[file]
		if comp_or_group is TwitchGenComponent:
			add_component(comp_or_group, file_row)
		else:			
			for component in comp_or_group.components:
				add_component(component, file_row)


func add_component(component: TwitchGenComponent, parent: TreeItem = null) -> TreeItem:
	var component_row: TreeItem = components_tree.create_item(parent)
	ref_item_map[component._ref] = component_row
	ref_item_map[component._classname] = component_row
	
	component_row.set_text(0, component._classname)
	component_row.set_text(1, component._ref)
	
	for field in component._fields:
		var field_row: TreeItem = components_tree.create_item(component_row)
		field_row.set_text(2, field._name)
		field_row.set_text(3, field._type)
		var mods = ""
		mods += "R" if field._is_required else "O"
		mods += "A" if field._is_array else "-"
		field_row.set_text(4, mods)
		
	
	for sub_component: TwitchGenComponent in component._sub_components.values():
		add_component(sub_component, component_row)
		
	return component_row

func _on_search_component(text: String) -> void:
	var item = ref_item_map.get(text)
	if item != null: components_tree.scroll_to_item(item, true)

func _on_search_method(text: String) -> void:
	var item = method_item_map.get(text)
	if item != null: methods_tree.scroll_to_item(item, true)
