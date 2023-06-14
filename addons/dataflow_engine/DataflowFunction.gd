@tool
class_name DataflowFunction extends Resource

const DataflowFunctionParameter = preload("DataflowFunctionParameter.gd")
const ObjectHelper = preload("ObjectHelper.gd")

var _object_helper := ObjectHelper.new()

var _inputs: Array[DataflowFunctionParameter] = []
var _outputs: Array[DataflowFunctionParameter] = []

var _inputs_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("input",
		func (): return DataflowFunctionParameter.new(),
		func (): changed.emit(); property_list_changed.emit())
var _outputs_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("output",
		func (): return DataflowFunctionParameter.new(),
		func (): changed.emit(); property_list_changed.emit())

func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())
	
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append_array(_object_helper.get_array_property_list(_inputs, _inputs_array_property_preset))
	properties.append_array(_object_helper.get_array_property_list(_outputs, _outputs_array_property_preset))
	return properties

func _set(property: StringName, value: Variant):
	if _object_helper.is_array_property(property, _inputs_array_property_preset):
		_object_helper.set_array_property(property, value, _inputs, _inputs_array_property_preset)
	elif _object_helper.is_array_property(property, _outputs_array_property_preset):
		_object_helper.set_array_property(property, value, _outputs, _outputs_array_property_preset)

func _get(property: StringName) -> Variant:
	if _object_helper.is_array_property(property, _inputs_array_property_preset):
		return _object_helper.get_array_property(property, _inputs, _inputs_array_property_preset)
	elif _object_helper.is_array_property(property, _outputs_array_property_preset):
		return _object_helper.get_array_property(property, _outputs, _outputs_array_property_preset)
	return null

func _emit_property_list_changed():
	property_list_changed.emit()

func get_inputs() -> Array[DataflowFunctionParameter]:
	return _inputs.duplicate()

func get_outputs() -> Array[DataflowFunctionParameter]:
	return _outputs.duplicate()
