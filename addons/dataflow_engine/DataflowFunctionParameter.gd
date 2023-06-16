@tool
extends "DataflowDataType.gd"

var _disable_change_emit := false

var display_name: String = "":
	set(new_value):
		if new_value != display_name:
			display_name = new_value
			_disable_change_emit = true
			generated_identifier = _object_helper.generate_identifier(display_name)
			if identifier.is_empty():
				identifier_changed.emit(self)
			_disable_change_emit = false
			changed.emit()

var identifier: String = "":
	set(new_value):
		if new_value != identifier:
			identifier = new_value
			_disable_change_emit = true
			generated_display_name = _object_helper.generate_display_name(identifier)
			_disable_change_emit = false
			changed.emit()
			identifier_changed.emit(self)

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
			return _object_helper.generate_display_name(identifier) if identifier != null and not identifier.is_empty() else _object_helper.generate_display_name(generated_identifier)

var generated_identifier: String = "":
	set(new_value):
		if new_value != generated_identifier:
			generated_identifier = new_value
			if not _disable_change_emit:
				changed.emit()
				identifier_changed.emit(self)
	get:
		if generated_identifier != null and not generated_identifier.is_empty():
			return generated_identifier
		else:
			return _object_helper.generate_identifier(display_name)

signal identifier_changed(parameter: DataflowFunction.DataflowFunctionParameter)

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
	properties.append({
		"name": "generated_display_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "generated_identifier",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE,
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
		"generated_display_name":
			generated_display_name = value
		"generated_identifier":
			generated_identifier = value

func _get(property: StringName) -> Variant:
	match property:
		"display_name":
			return display_name
		"identifier":
			return identifier
		"generated_display_name":
			return generated_display_name
		"generated_identifier":
			return generated_identifier
	return null
	
