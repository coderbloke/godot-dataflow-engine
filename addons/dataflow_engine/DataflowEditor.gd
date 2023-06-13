@tool
extends GraphEdit

class DataflowEditorNode extends GraphNode:
	var dataflow_graph_node: DataflowGraph.DataflowNode

var editor_interface: EditorInterface

var add_button := Button.new()

var dataflow_graph_nodes: Array[DataflowEditorNode]

func _init():
	add_button.text = "Add"
	add_button.flat = true
	add_button.pressed.connect(_on_add_button_pressed)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	pass


func _ready():
	var inner_toolbar := get_zoom_hbox()
	inner_toolbar.add_child(add_button) 
	inner_toolbar.move_child(add_button, 0)
	pass


func _on_add_button_pressed():
	var node := DataflowEditorNode.new()
	node.size = Vector2(120, 60)
	add_child(node)


func _on_node_selected(node: GraphNode):
	if editor_interface != null:
		editor_interface.inspect_object(node)


func _on_node_deselected(node: GraphNode):
	if editor_interface != null:
		editor_interface.inspect_object(null)
