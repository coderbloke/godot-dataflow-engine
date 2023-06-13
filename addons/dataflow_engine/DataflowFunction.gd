@tool
class_name DataflowFunction extends Resource

const DataflowFunctionParameter = preload("DataflowFunctionParameter.gd")

var _object_helper := preload("ObjectHelper.gd").new()

var _inputs: Array[DataflowFunctionParameter] = []
var _outputs: Array[DataflowFunctionParameter] = []

func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())
	pass
	
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "input_count",
		"class_name": "Inputs,input_,add_button_text=Add Input,page_size=10",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	for i in _inputs.size():
		_inputs[i] = _object_helper.create_and_connect_if_necessary(_inputs[i], func (): return DataflowFunctionParameter.new())
		properties.append_array(_object_helper.get_child_property_list(_inputs[i], "input_%s/" % i))
	return properties

func _set(property: StringName, value: Variant):
	print("[DataflowFunction._set] %s = %s" % [property, value])
	if property == "input_count":
		if value != _inputs.size():
			_inputs.resize(value)
			property_list_changed.emit()
	elif property.begins_with("input_"):
		var slash_pos = property.find("/")
		var i := property.substr(0, slash_pos).get_slice("_", 1).to_int()
		_inputs[i] = _object_helper.create_and_connect_if_necessary(_inputs[i], func (): return DataflowFunctionParameter.new())
		_inputs[i].set(property.substr(slash_pos + 1), value)

func _get(property: StringName) -> Variant:
	if property == "input_count":
		return _inputs.size()
	elif property.begins_with("input_"):
		var slash_pos = property.find("/")
		var i := property.substr(0, slash_pos).get_slice("_", 1).to_int()
		_inputs[i] = _object_helper.create_and_connect_if_necessary(_inputs[i], func (): return DataflowFunctionParameter.new())
		return _inputs[i].get(property.substr(slash_pos + 1))
	return null

func _emit_property_list_changed():
	property_list_changed.emit()
