@icon("Dataflow.svg")
@tool
class_name DataflowGraph extends Resource

const DataflowNode = preload("DataflowNode.gd")
const ObjectHelper = preload("ObjectHelper.gd")

var _nodes: Array[DataflowNode] = []:
	set(new_value):
		_nodes = new_value
		_update_node_identifiers(null)

var _object_helper := ObjectHelper.new()

var _nodes_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("node",
		func (): return DataflowNode.new(),
		func (): property_list_changed.emit())
var _node_identifier_preset := ObjectHelper.ChildIdentifierPreset.new("node",
		func (child): 
			return child.get_identifier())

func _init():
	_object_helper.add_signal_to_connect("changed",
		func (): 
			if not _updating_children:
				changed.emit())
	_object_helper.add_signal_to_connect("identifier_changed",
		func (node: DataflowNode):
			if not _updating_children:
				_update_node_identifiers(node)
				changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed",
		func (): 
			property_list_changed.emit())

var _updating_children := false

func _update_node_identifiers(triggering_node: DataflowNode):
	var new_id_per_child = _object_helper.generate_child_identifiers(_nodes, _node_identifier_preset, triggering_node)
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
	properties.append_array(_object_helper.get_array_property_list(_nodes, _nodes_array_property_preset))
	return properties

func _set(property: StringName, value: Variant):
	if _object_helper.is_array_property(property, _nodes_array_property_preset):
		_object_helper.set_array_property(property, value, _nodes, _nodes_array_property_preset)

func _get(property: StringName) -> Variant:
	if _object_helper.is_array_property(property, _nodes_array_property_preset):
		return _object_helper.get_array_property(property, _nodes, _nodes_array_property_preset)
	return null

func get_nodes():
	return _nodes.duplicate()

func add_node(node: DataflowNode):
	_nodes.append(node)
	_update_node_identifiers(node)
	changed.emit()
	property_list_changed.emit()

func remove_node(node: DataflowNode):
	_nodes.erase(node)
	_update_node_identifiers(node)
	changed.emit()
	property_list_changed.emit()

