extends RefCounted

## Contains all values that got actually changed
var _tracked: Dictionary[StringName, Variant] = {}


func _set(property: StringName, value: Variant) -> bool:
	_tracked[property] = value
	return false
		
		
func updated_values() -> Dictionary[StringName, Variant]:
	return _tracked
	
