@tool
extends GraphEdit

const EditorNode = preload("DataflowEditorNode.gd")

var editor_interface: EditorInterface

var add_button := Button.new()

var dataflow_graph: DataflowGraph:
	set(new_value):
		if dataflow_graph != null:
			dataflow_graph.changed.disconnect(_sync_editor_nodes_map)
		dataflow_graph = new_value
		_sync_editor_nodes_map()
		if dataflow_graph != null:
			dataflow_graph.changed.connect(_sync_editor_nodes_map)

var editor_nodes: Array[EditorNode]
var dataflow_nodes_to_editor_nodes := { }

func _init():
	add_button.text = "Add"
	add_button.flat = true
	add_button.pressed.connect(_on_add_button_pressed)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	dataflow_graph = preload("test_dataflow_graph.tres")
	custom_minimum_size = Vector2(0, 200)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _sync_editor_nodes_map():
	var removed_dataflow_nodes := []
	for dataflow_node in dataflow_nodes_to_editor_nodes:
		if dataflow_graph == null or not dataflow_node in dataflow_graph.get_nodes():
			removed_dataflow_nodes.append(dataflow_node)
	for dataflow_node in removed_dataflow_nodes:
		var editor_node = dataflow_nodes_to_editor_nodes[dataflow_node]
		remove_child(editor_node)
		editor_nodes.erase(editor_node)
		editor_node.queue_free()
		dataflow_nodes_to_editor_nodes.erase(dataflow_node)
	for dataflow_node in dataflow_graph.get_nodes():
		if not dataflow_node in dataflow_nodes_to_editor_nodes:
			var editor_node = EditorNode.new(dataflow_node)
			dataflow_nodes_to_editor_nodes[dataflow_node] = editor_node
			add_child(editor_node)

func _ready():
	var inner_toolbar := get_zoom_hbox()
	inner_toolbar.add_child(add_button) 
	inner_toolbar.move_child(add_button, 0)
	pass


func _on_add_button_pressed():
	var node := DataflowGraph.DataflowNode.new()
	dataflow_graph.add_node(node)


func _on_node_selected(node: GraphNode):
	if editor_interface != null:
		editor_interface.inspect_object(node.dataflow_node)


func _on_node_deselected(node: GraphNode):
	if editor_interface != null:
		editor_interface.inspect_object(dataflow_graph)
