@tool
extends "DataflowDataType.gd"

var name: String:
	set(new_value):
		if new_value != name:
			name = new_value
			changed.emit()

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	return properties

func _set(property: StringName, value: Variant):
	print("[DataflowFunctionParameter._set] %s" % property)
	match property:
		"name":
			name = value

func _get(property: StringName) -> Variant:
	match property:
		"name":
			return name
	return null
	
