@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGetModeratedChannelsResponse

## The list of channels that the user has moderator privileges in.
var data: Array[Data];
## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.
var pagination: Pagination;

static func from_json(d: Dictionary) -> TwitchGetModeratedChannelsResponse:
	var result = TwitchGetModeratedChannelsResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(Data.from_json(value));
	if d.has("pagination") && d["pagination"] != null:
		result.pagination = Pagination.from_json(d["pagination"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	if pagination != null:
		d["pagination"] = pagination.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## 
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

## Contains the information used to page through the list of results. The object is empty if there are no more pages left to page through.
class Pagination extends RefCounted:
{for properties as property}
	## {property.description}
	var {property.field_name}: {property.type};
{/for}


	static func from_json(d: Dictionary) -> Pagination:
		var result = Pagination.new();
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

