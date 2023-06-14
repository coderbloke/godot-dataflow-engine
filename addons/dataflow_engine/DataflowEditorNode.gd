@tool
extends GraphNode
	
const left_connector_icon = preload("LeftConnector.svg")
const right_connector_icon = preload("RightConnector.svg")

var dataflow_node: DataflowGraph.DataflowNode:
	set(new_value):
		if dataflow_node != null:
			dataflow_node.changed.disconnect(_sync_with_dataflow_node)
		dataflow_node = new_value
		_sync_with_dataflow_node()
		if dataflow_node != null:
			dataflow_node.changed.connect(_sync_with_dataflow_node)

var dataflow_function: DataflowFunction:
	set(new_value):
		if dataflow_function != null:
			dataflow_function.changed.disconnect(_sync_with_dataflow_function)
		dataflow_function = new_value
		_sync_with_dataflow_function()
		if dataflow_function != null:
			dataflow_function.changed.connect(_sync_with_dataflow_function)

func _init(dataflow_node: DataflowGraph.DataflowNode):
	self.dataflow_node = dataflow_node
	custom_minimum_size = Vector2(120, 60)
	var stylebox := StyleBoxEmpty.new()
	stylebox.content_margin_left = 8
	stylebox.content_margin_right = 8
	add_theme_stylebox_override("slot", stylebox)
	dragged.connect(_on_editor_node_dragged)

func _sync_with_dataflow_node():
	title = dataflow_node.title
	position_offset = dataflow_node.position
	if dataflow_node.function != dataflow_function:
		dataflow_function = dataflow_node.function

var slot_containers: Array[Container] = []

func _create_slot_label() -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	var stylebox = StyleBoxEmpty.new()
	stylebox.set_content_margin_all(2)
	label.add_theme_stylebox_override("normal", stylebox)
	return label

func _sync_with_dataflow_function():
	print("[_sync_with_dataflow_function]")
	var inputs := dataflow_function.get_inputs()
	var outputs := dataflow_function.get_outputs()
	var previous_slot_count := slot_containers.size()
	var slot_count := max(inputs.size(), outputs.size())
	for previous_slot_index in slot_containers.size():
		if previous_slot_index >= slot_count:
			remove_child(slot_containers[previous_slot_index])
			slot_containers[previous_slot_index].queue_free()
	slot_containers.resize(slot_count)
	for slot_index in slot_containers.size():
		if slot_index >= previous_slot_count:
			var slot_container := GridContainer.new()
			slot_container.columns = 2
			slot_container.mouse_filter = Control.MOUSE_FILTER_PASS
			slot_container.add_child(_create_slot_label()) # left label
			slot_container.add_child(_create_slot_label()) # right label
			slot_containers[slot_index] = slot_container
			add_child(slot_containers[slot_index])
	var connector_color = Color("cdcfd2")
	for slot_index in slot_count:
		var left_label = slot_containers[slot_index].get_child(0) as RichTextLabel
		var right_label = slot_containers[slot_index].get_child(1) as RichTextLabel
		set_slot(slot_index,
			slot_index < inputs.size(), 0, connector_color,
			slot_index < outputs.size(), 0, connector_color,
			left_connector_icon, right_connector_icon
		)
		left_label.text = inputs[slot_index].name if slot_index < inputs.size() and not inputs[slot_index].name.is_empty() else " "
		right_label.text = "[right]" + outputs[slot_index].name + "[/right]" if slot_index < outputs.size() and not outputs[slot_index].name.is_empty() else " "

func _on_editor_node_dragged(from: Vector2, to: Vector2):
	dataflow_node.position = to

