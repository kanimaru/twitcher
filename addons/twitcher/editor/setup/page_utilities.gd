@tool
extends MarginContainer

const script_path: String = "res://addons/twitcher/twitch_service.tscn"
const autoload_name: String = "Twitch"
const setting_key: String = "autoload/%s" % autoload_name
const setting_value: String = "*" + script_path

@onready var autoload_install: Button = %AutoloadInstall
@onready var autoload_info: Label = %AutoloadInfo
@onready var autoload_description: RichTextLabel = %AutoloadDescription


func _ready() -> void:
	autoload_description.text = autoload_description.text.format({
		"autoload_name": autoload_name
	})
	autoload_install.pressed.connect(_on_install_autoload_pressed)
	_update_install_autoload()
	
	
func _update_install_autoload() -> void:
	if ProjectSettings.has_setting(setting_key):
		autoload_install.text = "Uninstall Autoload"
	else:
		autoload_install.text = "Install Autoload"
		
	
func _on_install_autoload_pressed() -> void:
	if ProjectSettings.has_setting(setting_key):
		_uninstall_autoload()
	else:
		_install_autload()
	_update_install_autoload()
		
	
func _uninstall_autoload() -> void:
	ProjectSettings.clear(setting_key)
	
	var err = ProjectSettings.save()

	if err == OK:
		autoload_info.text = "Autoload '%s' uninstalled successfully!\nYou might need to reload the current project for changes to fully apply everywhere in the editor immediately." % autoload_name
		print("Successfully removed autoload: %s" % autoload_name)
	else:
		autoload_info.text = "Failed to save project settings.\nError code: %s" % error_string(err)
		printerr("Failed to save project settings! Error: ", error_string(err))
	
	
func _install_autload() -> void:
	if not FileAccess.file_exists(script_path):
		OS.alert("The TwitchService file does not exist at:\n" + script_path, "Error")
		return
		
	var setting_key: String = "autoload/%s" % autoload_name
	var setting_value: String = "*" + script_path
	if ProjectSettings.has_setting(setting_key):
		var existing_value = ProjectSettings.get_setting(setting_key)
		if existing_value == setting_value:
			autoload_info.text = "Autoload '%s' with the same path is already installed." % autoload_name
			return
		else:
			autoload_info.text = "Autoload '%s' already exists but points to a different path (%s)." % [autoload_name, existing_value]
			return
			
	ProjectSettings.set_setting(setting_key, setting_value)
	var err = ProjectSettings.save()

	if err == OK:
		autoload_info.text = "Autoload '%s' installed successfully!\nYou might need to reload the current project for changes to fully apply everywhere in the editor immediately." % autoload_name
		print("Successfully added autoload: %s -> %s" % [autoload_name, script_path])
	else:
		autoload_info.text = "Failed to save project settings.\nError code: %s" % error_string(err)
		printerr("Failed to save project settings! Error: ", error_string(err))
