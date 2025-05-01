extends Resource

## Base class to track which data got changed.
class_name TwitchData

## Contains all values that got actually changed
var _tracked: Dictionary[StringName, Variant] = {}


func track_data(property: StringName, value: Variant) -> bool:
	if value == null:
		_tracked.erase(property)
	elif value is Array:
		var serialized_value = []
		for value_entry in value:
			if "to_dict" in value_entry:
				serialized_value.append(value_entry.to_dict())
			else:
				serialized_value.append(value_entry)
		_tracked[property] = serialized_value
	elif typeof(value) == TYPE_OBJECT && value.is_class(self.get_class()):
		_tracked[property] = value.to_dict()
	else:
		_tracked[property] = value
	return false
		
		
func to_dict() -> Dictionary[StringName, Variant]:
	return _tracked
	
	
func to_json() -> String:
	return JSON.stringify(to_dict())
