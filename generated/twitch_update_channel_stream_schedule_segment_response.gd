@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateChannelStreamScheduleSegmentResponse

## The broadcaster’s streaming scheduled.
var data: Data;

static func from_json(d: Dictionary) -> TwitchUpdateChannelStreamScheduleSegmentResponse:
	var result = TwitchUpdateChannelStreamScheduleSegmentResponse.new();
	if d.has("data") && d["data"] != null:
		result.data = Data.from_json(d["data"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	if data != null:
		d["data"] = data.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The dates when the broadcaster is on vacation and not streaming. Is set to **null** if vacation mode is not enabled.
class Vacation extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Vacation:
		var result = Vacation.new();
{for properties as property}
{if property.is_property_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append(value);
{/if}
{if property.is_property_typed_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append({property.array_type}.from_json(value));
{/if}
{if property.is_property_sub_class}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = {property.type}.from_json(d["{property.property_name}"]);
{/if}
{if property.is_property_basic}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = d["{property.property_name}"];
{/if}
{/for}
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
{for properties as property}
{if property.is_property_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value);
{/if}
{if property.is_property_typed_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value.to_dict());
{/if}
{if property.is_property_sub_class}
		if {property.field_name} != null:
			d["{property.property_name}"] = {property.field_name}.to_dict();
{/if}
{if property.is_property_basic}
		d["{property.property_name}"] = {property.field_name};
{/if}
{/for}
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

## The broadcaster’s streaming scheduled.
class Data extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Data:
		var result = Data.new();
{for properties as property}
{if property.is_property_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append(value);
{/if}
{if property.is_property_typed_array}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			for value in d["{property.property_name}"]:
				result.{property.field_name}.append({property.array_type}.from_json(value));
{/if}
{if property.is_property_sub_class}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = {property.type}.from_json(d["{property.property_name}"]);
{/if}
{if property.is_property_basic}
		if d.has("{property.property_name}") && d["{property.property_name}"] != null:
			result.{property.field_name} = d["{property.property_name}"];
{/if}
{/for}
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
{for properties as property}
{if property.is_property_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value);
{/if}
{if property.is_property_typed_array}
		d["{property.property_name}"] = [];
		if {property.field_name} != null:
			for value in {property.field_name}:
				d["{property.property_name}"].append(value.to_dict());
{/if}
{if property.is_property_sub_class}
		if {property.field_name} != null:
			d["{property.property_name}"] = {property.field_name}.to_dict();
{/if}
{if property.is_property_basic}
		d["{property.property_name}"] = {property.field_name};
{/if}
{/for}
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

