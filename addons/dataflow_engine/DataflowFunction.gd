@icon("DataflowFunction.svg")
@tool
class_name DataflowFunction extends Resource

const DataflowFunctionParameter = preload("DataflowFunctionParameter.gd")
const ObjectHelper = preload("ObjectHelper.gd")

var _object_helper := ObjectHelper.new()

var _inputs: Array[DataflowFunctionParameter] = []:
	set(new_value):
		_inputs = new_value
		_update_input_parameter_identifiers(null)
var _outputs: Array[DataflowFunctionParameter] = []:
	set(new_value):
		_outputs = new_value
		_update_output_parameter_identifiers(null)

var _inputs_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("input",
		func (): 
			return DataflowFunctionParameter.new(),
		func (): 
			_update_input_parameter_identifiers(null)
			changed.emit() 
			property_list_changed.emit())
var _outputs_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("output",
		func (): 
			return DataflowFunctionParameter.new(),
		func (): 
			_update_output_parameter_identifiers(null)
			changed.emit()
			property_list_changed.emit())
var _input_identifier_preset := ObjectHelper.ChildIdentifierPreset.new("input",
		func (child): 
			return child.get_identifier())
var _output_identifier_preset := ObjectHelper.ChildIdentifierPreset.new("output",
		func (child):
			return child.get_identifier())

var default_display_name: String = "":
	set(new_value):
		if new_value != default_display_name:
			default_display_name = new_value
			changed.emit()
var default_identifier: String = "":
	set(new_value):
		if new_value != default_identifier:
			default_identifier = new_value
			changed.emit()

func _init():
	_object_helper.add_signal_to_connect("changed",
		func (): 
			if not _updating_children:
				changed.emit())
	_object_helper.add_signal_to_connect("identifier_changed",
		func (parameter: DataflowFunctionParameter):
			if not _updating_children:
				_update_parameter_identifiers(parameter)
				changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed",
		func (): 
			property_list_changed.emit())

var _updating_children := false

func _update_parameter_identifiers(triggering_parameter: DataflowFunctionParameter):
	if triggering_parameter in _inputs:
		_update_input_parameter_identifiers(triggering_parameter)
	elif triggering_parameter in _outputs:
		_update_output_parameter_identifiers(triggering_parameter)

func _update_input_parameter_identifiers(triggering_parameter: DataflowFunctionParameter):
	var new_id_per_child = _object_helper.generate_child_identifiers(_inputs, _input_identifier_preset, triggering_parameter)
	_set_new_parameter_identifiers(new_id_per_child)
	
func _update_output_parameter_identifiers(triggering_parameter: DataflowFunctionParameter):
	var new_id_per_child = _object_helper.generate_child_identifiers(_outputs, _output_identifier_preset, triggering_parameter)
	_set_new_parameter_identifiers(new_id_per_child)
	
func _set_new_parameter_identifiers(new_id_per_child: Dictionary):
	_updating_children = true
	for child in new_id_per_child:
		if child.identifier.is_empty():
			child.generated_identifier = new_id_per_child[child]
		else:
			child.identifier = new_id_per_child[child]
	_updating_children = false

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append_array(_object_helper.get_array_property_list(_inputs, _inputs_array_property_preset))
	properties.append_array(_object_helper.get_array_property_list(_outputs, _outputs_array_property_preset))
	properties.append(_object_helper.get_single_property_info("default_naming/display_name", TYPE_STRING))
	properties.append(_object_helper.get_single_property_info("default_naming/identifier", TYPE_STRING))
	return properties

func _set(property: StringName, value: Variant):
	if _object_helper.is_array_property(property, _inputs_array_property_preset):
		_object_helper.set_array_property(property, value, _inputs, _inputs_array_property_preset)
	elif _object_helper.is_array_property(property, _outputs_array_property_preset):
		_object_helper.set_array_property(property, value, _outputs, _outputs_array_property_preset)
	elif property == "default_naming/display_name":
		default_display_name = value
	elif property == "default_naming/identifier":
		default_identifier = value

func _get(property: StringName) -> Variant:
	if _object_helper.is_array_property(property, _inputs_array_property_preset):
		return _object_helper.get_array_property(property, _inputs, _inputs_array_property_preset)
	elif _object_helper.is_array_property(property, _outputs_array_property_preset):
		return _object_helper.get_array_property(property, _outputs, _outputs_array_property_preset)
	elif property == "default_naming/display_name":
		return default_display_name
	elif property == "default_naming/identifier":
		return default_identifier
	return null

func _emit_property_list_changed():
	property_list_changed.emit()

func get_inputs() -> Array[DataflowFunctionParameter]:
	return _inputs.duplicate()

func get_outputs() -> Array[DataflowFunctionParameter]:
	return _outputs.duplicate()
