@tool
extends GraphNode
	
const left_connector_icon = preload("LeftConnector.svg")
const right_connector_icon = preload("RightConnector.svg")

var _slot_style_box := StyleBoxEmpty.new()

var default_connector_color := Color.WHITE

var _centered_title := TextLine.new()

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
#	custom_minimum_size = Vector2(120, 0)
	dragged.connect(_on_editor_node_dragged)

var _updating_theme := false

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE, \
		NOTIFICATION_THEME_CHANGED:
			if not _updating_theme:
				_updating_theme = true
				_slot_style_box = get_theme_stylebox("slot").duplicate()
				_slot_style_box.content_margin_left = 8
				_slot_style_box.content_margin_right = 8
				add_theme_stylebox_override("slot", _slot_style_box)
				_update_size()
				default_connector_color = get_theme_color("font_color", "Editor")
				_sync_with_dataflow_node() # because default slot color
				_sync_with_dataflow_function() # Because title font and size
				_updating_theme = false
		NOTIFICATION_DRAW:
			var title_pos := Vector2(size.x / 2 - _centered_title.get_size().x / 2,
				get_theme_constant("title_offset") - _centered_title.get_size().y)
			_centered_title.draw(get_canvas_item(), title_pos, get_theme_color("title_color"))

func _update_size():
	custom_minimum_size = Vector2(_slot_style_box.content_margin_left + _centered_title.get_size().x + _slot_style_box.content_margin_right, 0)
	size = Vector2(0, 0)

func _sync_with_dataflow_node():
#	title = dataflow_node.get_display_name()
	_centered_title.clear()
	_centered_title.add_string(dataflow_node.get_display_name(), get_theme_font("title_font"), get_theme_font_size("title_font_size"))
	_update_size()
	queue_redraw()
	position_offset = dataflow_node.diagram_position
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
	var inputs = dataflow_function.get_inputs() if dataflow_function != null else []
	var outputs = dataflow_function.get_outputs() if dataflow_function != null else []
	var previous_slot_count := slot_containers.size()
	var slot_count := max(inputs.size(), outputs.size(), 1)
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
	var connector_color = default_connector_color
	for slot_index in slot_count:
		var left_label = slot_containers[slot_index].get_child(0) as RichTextLabel
		var right_label = slot_containers[slot_index].get_child(1) as RichTextLabel
		set_slot(slot_index,
			slot_index < inputs.size(), 0, connector_color,
			slot_index < outputs.size(), 0, connector_color,
			left_connector_icon, right_connector_icon
		)
		left_label.text = inputs[slot_index].get_display_name() \
				if slot_index < inputs.size() \
				and inputs[slot_index] != null \
				and not inputs[slot_index].get_display_name().is_empty() \
				else " "
		right_label.text = "[right]" + outputs[slot_index].get_display_name() + "[/right]" \
				if slot_index < outputs.size() \
				and outputs[slot_index] != null \
				and not outputs[slot_index].get_display_name().is_empty() \
				else " "

func _on_editor_node_dragged(from: Vector2, to: Vector2):
	dataflow_node.diagram_position = to

