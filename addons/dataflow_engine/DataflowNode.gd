@tool
extends RefCounted

const ObjectHelper = preload("ObjectHelper.gd")

@export var function: DataflowFunction:
	set(new_value):
		if new_value != function:
			function = _object_helper.update_child_connection(function, new_value)
			changed.emit()
var title: String:
	set(new_value):
		if new_value != title:
			title = new_value
			changed.emit()
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
		"name": "visuals/title",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "visuals/position",
		"type": TYPE_VECTOR2,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	return properties

func _set(property: StringName, value: Variant):
	match property:
		"visuals/title":
			title = value
		"visuals/position":
			position = value

func _get(property: StringName) -> Variant:
	match property:
		"visuals/title":
			return title
		"visuals/position":
			return position
	return null
	
