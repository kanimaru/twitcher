@tool
extends Resource

## Contains the information about a set of scopes.
class_name OAuthScopes

## Called when new scopes was added or removed
signal scopes_changed

@export var used_scopes: Array[StringName] = []:
	set(val):
		used_scopes = val;
		scopes_changed.emit()


## Returns the scopes space separated
func ssv_scopes() -> String:
	return " ".join(used_scopes)


func add_scopes(scopes: Array[StringName]) -> void:
	for scope in scopes:
		if used_scopes.find(scope) != -1: continue
		used_scopes.append(scope)
	scopes_changed.emit()


func remove_scopes(scopes: Array[StringName]) -> void:
	used_scopes = used_scopes.filter(func(s): return scopes.find(s) != -1)
	scopes_changed.emit()
