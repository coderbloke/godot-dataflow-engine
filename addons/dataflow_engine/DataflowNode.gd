@tool
extends RefCounted

const ObjectHelper = preload("ObjectHelper.gd")

var _disable_change_emit_requests := 0

var display_name: String = "":
	set(new_value):
		if new_value != display_name:
			display_name = new_value
			_disable_change_emit_requests += 1
			_generate_display_name_and_identifier()
			_disable_change_emit_requests -= 1
			changed.emit()

var identifier: String = "":
	set(new_value):
		if new_value != identifier:
			identifier = new_value
			_disable_change_emit_requests += 1
			_generate_display_name_and_identifier()
			_disable_change_emit_requests -= 1
			identifier_changed.emit(self)
			changed.emit()

var generated_display_name: String = "":
	set(new_value):
		if new_value != generated_display_name:
			generated_display_name = new_value
			if not _disable_change_emit_requests > 0:
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
			if identifier == null or identifier.is_empty(): # So generated identifer is used
				identifier_changed.emit(self)
			if not _disable_change_emit_requests > 0:
				changed.emit()
	get:
		if generated_identifier != null and not generated_identifier.is_empty():
			return generated_identifier
		else:
			return _object_helper.generate_identifier(display_name)

func _generate_display_name_and_identifier():
	if display_name != null and not display_name.is_empty():
		generated_display_name = display_name
	elif function != null and not function.get_default_display_name().is_empty():
		generated_display_name = function.get_default_display_name()
	else:
		generated_display_name = _object_helper.generate_display_name(identifier)
	if identifier != null and not identifier.is_empty():
		generated_identifier = identifier
	elif function != null and not function.get_default_identifier().is_empty():
		generated_identifier = function.get_default_identifier()
	else:
		generated_identifier = _object_helper.generate_identifier(display_name)

signal identifier_changed(parameter: DataflowGraph.DataflowNode)

func get_display_name():
	return display_name if not display_name.is_empty() else generated_display_name

func get_identifier():
	return identifier if not identifier.is_empty() else generated_identifier

var function: DataflowFunction:
	set(new_value):
		if new_value != function:
			if function != null:
				function.changed.disconnect(_generate_display_name_and_identifier)
			function = _object_helper.update_child_connection(function, new_value)
			_generate_display_name_and_identifier()
			if function != null:
				function.changed.connect(_generate_display_name_and_identifier)
			changed.emit()
			
var diagram_position: Vector2:
	set(new_value):
		if new_value != diagram_position:
			diagram_position = new_value
			changed.emit()

signal changed()

var _object_helper := ObjectHelper.new()

func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append(_object_helper.get_single_property_info("display_name", TYPE_STRING))
	properties.append(_object_helper.get_single_property_info("identifier", TYPE_STRING))
	properties.append(_object_helper.get_single_property_info("generated_display_name", TYPE_STRING,
			PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY))
	properties.append(_object_helper.get_single_property_info("generated_identifier", TYPE_STRING,
			PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY))
	properties.append({
		"name": "function",
		"class_name": "Resource",
		"type": TYPE_OBJECT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "DataflowFunction"
	})
	properties.append({
		"name": "diagram/position",
		"type": TYPE_VECTOR2,
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
		"function":
			function = value
		"diagram/position":
			diagram_position = value

func _get(property: StringName) -> Variant:
	match property:
		"display_name":
			return display_name
		"identifier":
			return identifier
		"function":
			return function
		"diagram/position":
			return diagram_position
	return null
	
