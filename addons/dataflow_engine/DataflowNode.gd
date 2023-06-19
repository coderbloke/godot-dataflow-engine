@tool
extends RefCounted

const ObjectHelper = preload("ObjectHelper.gd")

var _disable_change_emit := false

var display_name: String = "":
	set(new_value):
		if new_value != display_name:
			display_name = new_value
			_disable_change_emit = true
			_generated_display_name_and_identifier()
			_disable_change_emit = false
			changed.emit()

var identifier: String = "":
	set(new_value):
		if new_value != identifier:
			identifier = new_value
			_disable_change_emit = true
			_generated_display_name_and_identifier()
			_disable_change_emit = false
			identifier_changed.emit(self)
			changed.emit()

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
			var previous_identifier = get_identifier()
			generated_identifier = new_value
			if not _disable_change_emit:
				if identifier == null or identifier.is_empty(): # So generated identifer is used
					identifier_changed.emit(self)
				changed.emit()
	get:
		if generated_identifier != null and not generated_identifier.is_empty():
			return generated_identifier
		else:
			return _object_helper.generate_identifier(display_name)

func _generated_display_name_and_identifier():
	if display_name != null and not display_name.is_empty():
		generated_display_name = display_name
	else:
		generated_display_name = _object_helper.generate_display_name(identifier)
	if identifier != null and not identifier.is_empty():
		generated_identifier = identifier
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
			function = _object_helper.update_child_connection(function, new_value)
			changed.emit()
			
#var title: String:
#	set(new_value):
#		if new_value != title:
#			title = new_value
#			changed.emit()

var position: Vector2:
	set(new_value):
		if new_value != position:
			position = new_value
			changed.emit()

signal changed()

var _object_helper := ObjectHelper.new()

func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())

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
			position = value

func _get(property: StringName) -> Variant:
	match property:
		"display_name":
			return display_name
		"identifier":
			return identifier
		"function":
			return function
		"diagram/position":
			return position
	return null
	
