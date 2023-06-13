@tool
extends RefCounted

const DataflowDataType = preload("DataflowDataType.gd")

enum Type {
	ANY = -1,
	BOOL = Variant.Type.TYPE_BOOL, # 1
	INT = Variant.Type.TYPE_INT, # 2
	FLOAT = Variant.Type.TYPE_FLOAT, # 3
	STRING = Variant.Type.TYPE_STRING, # 4
	VECTOR2 = Variant.Type.TYPE_VECTOR2, # 5
	VECTOR2I = Variant.Type.TYPE_VECTOR2I, # 6
	RECT2 = Variant.Type.TYPE_RECT2, # 7
	RECT2I = Variant.Type.TYPE_RECT2I, # 8
	VECTOR3 = Variant.Type.TYPE_VECTOR3, # 9
	VECTOR3I = Variant.Type.TYPE_VECTOR3I, # 10
	TRANSFORM2D = Variant.Type.TYPE_TRANSFORM2D, # 11
	VECTOR4 = Variant.Type.TYPE_VECTOR4, # 12
	VECTOR4I = Variant.Type.TYPE_VECTOR4I, # 13
	PLANE = Variant.Type.TYPE_PLANE, # 14
	QUATERNION = Variant.Type.TYPE_QUATERNION, # 15
	AABB = Variant.Type.TYPE_AABB, # 16
	BASIS = Variant.Type.TYPE_BASIS, # 17
	TRANSFORM3D = Variant.Type.TYPE_TRANSFORM3D, # 18
	PROJECTION = Variant.Type.TYPE_PROJECTION, # 19
	COLOR = Variant.Type.TYPE_COLOR, # 20
	STRING_NAME = Variant.Type.TYPE_STRING_NAME, # 21
	NODE_PATH = Variant.Type.TYPE_NODE_PATH, # 22
	RID = Variant.Type.TYPE_RID, # 23
	OBJECT = Variant.Type.TYPE_OBJECT, # 24
	CALLABLE = Variant.Type.TYPE_CALLABLE, # 25
	SIGNAL = Variant.Type.TYPE_SIGNAL, # 26
	DICTIONARY = Variant.Type.TYPE_DICTIONARY, # 27
	ARRAY = Variant.Type.TYPE_ARRAY, # 28
	PACKED_BYTE_ARRAY = Variant.Type.TYPE_PACKED_BYTE_ARRAY, # 29
	PACKED_INT32_ARRAY = Variant.Type.TYPE_PACKED_INT32_ARRAY, # 30
	PACKED_INT64_ARRAY = Variant.Type.TYPE_PACKED_INT64_ARRAY, # 31
	PACKED_FLOAT32_ARRAY = Variant.Type.TYPE_PACKED_FLOAT32_ARRAY, # 32
	PACKED_FLOAT64_ARRAY = Variant.Type.TYPE_PACKED_FLOAT64_ARRAY, # 33
	PACKED_STRING_ARRAY = Variant.Type.TYPE_PACKED_STRING_ARRAY, # 34
	PACKED_VECTOR2_ARRAY = Variant.Type.TYPE_PACKED_VECTOR2_ARRAY, # 35
	PACKED_VECTOR3_ARRAY = Variant.Type.TYPE_PACKED_VECTOR3_ARRAY, # 36
	PACKED_COLOR_ARRAY = Variant.Type.TYPE_PACKED_COLOR_ARRAY, # 37
}

# Using this map direct can bring insconsistency.
# TODO: Type name list for inspector should be made by a function, but it's OK for now.
const TypeNameMap = {
	Type.ANY : "Any",
	Type.BOOL : "bool",
	Type.INT : "int",
	Type.FLOAT : "float",
	Type.STRING : "String",
	Type.VECTOR2 : "Vector2",
	Type.VECTOR2I : "Vector2i",
	Type.RECT2 : "Rect2",
	Type.RECT2I : "Rect2i",
	Type.VECTOR3 : "Vector3",
	Type.VECTOR3I : "Vector3i",
	Type.TRANSFORM2D : "Transform2D",
	Type.VECTOR4 : "Vector4",
	Type.VECTOR4I : "Vector4i",
	Type.PLANE : "Plane",
	Type.QUATERNION : "Quaternion",
	Type.AABB : "AABB",
	Type.BASIS : "Basis",
	Type.TRANSFORM3D : "Transform3D",
	Type.PROJECTION : "Projection",
	Type.COLOR : "Color",
	Type.STRING_NAME : "StringName",
	Type.NODE_PATH : "NodePath",
	Type.RID : "RID",
	Type.OBJECT : "Object",
	Type.CALLABLE : "Callable",
	Type.SIGNAL : "Signal",
	Type.DICTIONARY : "Dictionary",
	Type.ARRAY : "Array",
	Type.PACKED_BYTE_ARRAY : "PackedByteArray",
	Type.PACKED_INT32_ARRAY : "PackedInt32Array",
	Type.PACKED_INT64_ARRAY : "PackedInt64Array",
	Type.PACKED_FLOAT32_ARRAY : "PackedFloat32Array",
	Type.PACKED_FLOAT64_ARRAY : "PackedFloat64Array",
	Type.PACKED_STRING_ARRAY : "PackedStringArray",
	Type.PACKED_VECTOR2_ARRAY : "PackedVector2Array",
	Type.PACKED_VECTOR3_ARRAY : "PackedVector3Array",
	Type.PACKED_COLOR_ARRAY : "PackedColorArray",
}

var type: int:
	set (new_value):
		if new_value != type:
			var old_value = type
			type = new_value
			changed.emit()
			# These types has additional properties
			if new_value == Type.ARRAY and element_type == null:
				element_type = DataflowDataType.new()
			if old_value in [Type.OBJECT, Type.ARRAY, Type.SIGNAL, Type.CALLABLE] \
					or new_value in [Type.OBJECT, Type.ARRAY, Type.SIGNAL, Type.CALLABLE]:
				property_list_changed.emit()

var type_class: String:
	set(new_value):
		if new_value != type_class:
			type_class = new_value
			changed.emit()

var element_type: DataflowDataType:
	set(new_value):
		if new_value != element_type:
			element_type = _object_helper.update_child_connection(element_type, new_value)
			changed.emit()

signal changed()

var _object_helper := preload("ObjectHelper.gd").new()


func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "type",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(TypeNameMap.values())
	})
	properties.append({
		"name": "class",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT if type == Type.OBJECT else PROPERTY_USAGE_NONE,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": ""
	})
	if type == Type.ARRAY: # Keep like this, otherwise there will be infinite recursion
		properties.append_array(_object_helper.get_child_property_list(element_type, "element_type/"))
	return properties


func _set(property: StringName, value: Variant):
	print("[DataflowDataType._set] %s = %s" % [property, value])
	if property == "type":
		type = value
	elif property == "class":
		type_class = value
	elif property.begins_with("element_type/"):
		element_type.set(property.trim_prefix("element_type/"), value)


func _get(property: StringName) -> Variant:
	if property == "type":
		return type
	elif property == "class":
		return type_class
	elif property.begins_with("element_type/"):
		return element_type.get(property.trim_prefix("element_type/"))
	return null


