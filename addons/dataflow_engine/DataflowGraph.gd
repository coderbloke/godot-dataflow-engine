@icon("Dataflow.svg")
@tool
class_name DataflowGraph extends Resource

const DataflowNode = preload("DataflowNode.gd")
const ObjectHelper = preload("ObjectHelper.gd")

var _nodes: Array[DataflowNode] = []

var _object_helper := ObjectHelper.new()

var _nodes_array_property_preset := ObjectHelper.ArrayPropertyPreset.new("node",
		func (): return DataflowNode.new(),
		func (): property_list_changed.emit())

func _init():
	_object_helper.add_signal_to_connect("changed", func (): changed.emit())
	_object_helper.add_signal_to_connect("property_list_changed", func (): property_list_changed.emit())

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
	print("[DataflowGraph.add_node]")
	_nodes.append(node)
	changed.emit()
	property_list_changed.emit()

func remove_node(node: DataflowNode):
	_nodes.erase(node)
	changed.emit()
	property_list_changed.emit()

