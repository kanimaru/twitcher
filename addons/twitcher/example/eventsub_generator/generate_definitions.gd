extends Control

## The already-parsed eventsub schemas (shared with the Eventsub payload generator), used to look
## up condition fields.
@export var api_parser: TwitchAPIParser
@export var definition_parser: TwitchEventsubDefinitionParser
@export var definition_generator: TwitchEventsubDefinitionGenerator

@onready var generate: Button = %Generate
@onready var status: Label = %Status


func _ready() -> void:
	generate.pressed.connect(_on_generate)


func _on_generate() -> void:
	status.text = "Parsing subscription types..."
	if api_parser.components.is_empty():
		await api_parser.parse_api()
	await definition_parser.parse_subscription_types()
	definition_generator.generate(definition_parser.definitions)
	status.text = "Done: %s definitions regenerated." % definition_parser.definitions.size()
