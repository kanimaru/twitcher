@icon("res://addons/twitcher/assets/twitcher-icon.svg")
extends Node

## Parent class to group all Twitcher relevant nodes.
class_name Twitcher

## Version of the addon. Must match [code]plugin.cfg[/code]; a test checks it.
## Kept in code because exported games don't ship [code]plugin.cfg[/code].
const VERSION: String = "2.5.1"
