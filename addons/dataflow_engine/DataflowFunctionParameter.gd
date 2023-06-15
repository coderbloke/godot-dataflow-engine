@tool
extends "DataflowDataType.gd"

var _disable_change_emit := false

var display_name: String = "":
	set(new_value):
		if new_value != display_name:
			display_name = new_value
			_disable_change_emit = true
			generated_identifier = _generate_identifier(display_name)
			_disable_change_emit = false
			changed.emit()

var identifier: String = "":
	set(new_value):
		if new_value != identifier:
			identifier = new_value
			_disable_change_emit = true
			generated_display_name = _generate_display_name(identifier)
			_disable_change_emit = false
			changed.emit()
			identifier_changed.emit()

var generated_display_name: String = "":
	set(new_value):
		if new_value != generated_display_name:
			generated_display_name = new_value
			if not _disable_change_emit:
				changed.emit()
	get:
		if generated_display_name != null and not generated_display_name.is_empty():
			return generated_display_name
		else:
			return _generate_display_name(identifier)

var generated_identifier: String = "":
	set(new_value):
		if new_value != generated_identifier:
			if not _disable_change_emit:
				changed.emit()
				identifier_changed.emit()
	get:
		if generated_identifier != null and not generated_identifier.is_empty():
			return generated_identifier
		else:
			return _generate_identifier(display_name)

signal identifier_changed()

func _generate_display_name(identififer: String) -> String:
	if identififer.is_empty():
		return ""
	var previous_char_was_space := false
	var display_name =  identififer.to_snake_case().replace("_", " ")
	display_name = display_name[0].capitalize() + display_name.substr(1)
	return display_name

func _generate_identifier(display_name: String) -> String:
	return display_name.to_snake_case()

func get_display_name():
	return display_name if not display_name.is_empty() else generated_display_name

func get_identifier():
	return identifier if not identifier.is_empty() else generated_identifier

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "display_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "identifier",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	return properties

func _set(property: StringName, value: Variant):
	match property:
		"display_name":
			display_name = value
		"identifier":
			identifier = value

func _get(property: StringName) -> Variant:
	match property:
		"display_name":
			return display_name
		"identifier":
			return identifier
	return null
	
