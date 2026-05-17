@tool
extends Node

const SectionDefaultUserView = preload("uid://bkvsg1os5pj6a")
const SectionAuthorizationView = preload("uid://c601gt6x3ydpq")
const SectionDefaultResourceView = preload("uid://b28mmhk5a83yy")

@onready var to_documentation: Button = %ToDocumentation

@onready var authorization_view: SectionAuthorizationView = %AuthorizationView
@onready var default_user_view: SectionDefaultUserView = %DefaultUserView
@onready var default_ressource_view: SectionDefaultResourceView = %DefaultRessourceView

@onready var default_resource: FoldableContainer = %DefaultResource
@onready var default_user: FoldableContainer = %DefaultUser

signal changed

var has_changes: bool:
	get():
		return authorization_view.has_changes \
			or default_user_view.has_changes \
			or default_ressource_view.has_changes


func _ready() -> void:
	to_documentation.pressed.connect(_on_to_documentation_pressed)
	authorization_view.authorized.connect(_on_authorized)
	_set_unauthorized()


func _set_authorized() -> void:
	default_user.show()
	default_resource.show()
	default_user.expand()


func _set_unauthorized() -> void:
	default_resource.hide()
	default_user.hide()


func _on_authorized() -> void:
	_set_authorized()


func _on_to_documentation_pressed() -> void:
	OS.shell_open("https://dev.twitch.tv/docs/authentication/")
