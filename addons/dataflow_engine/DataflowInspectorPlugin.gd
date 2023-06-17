@tool
extends EditorInspectorPlugin

class PropertyLineEdit extends EditorProperty:

	var update_trigger: Signal
	var placeholder_property: String
	
	var line_edit: LineEdit
	var _updating := false
	var update_only_on_exit_focus = true
	
	func _init(update_trigger: Signal, placeholder_property: String):
		self.update_trigger = update_trigger
		self.placeholder_property = placeholder_property
		line_edit = LineEdit.new()
		update_trigger.connect(update_line_edit)
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.focus_exited.connect(update_line_edit)
		add_child(line_edit)
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			update_trigger.disconnect(update_line_edit)

	func _update_property():
		print("[_update_property]")
		update_line_edit()

	func update_line_edit():
		if update_only_on_exit_focus and line_edit.has_focus():
			return
		var placeholder_text = get_edited_object().get(placeholder_property)
		if placeholder_text != line_edit.placeholder_text:
			line_edit.placeholder_text = placeholder_text
		var text = get_edited_object().get(get_edited_property())
		if text != line_edit.text:
			line_edit.text = text
			line_edit.caret_column = text.length()
#		if not _updating:
#			line_edit.placeholder_text = placeholder_getter.call()
#			line_edit.text = text_getter.call()

	func _on_text_changed(text: String):
		_updating = true
		get_edited_object().set(get_edited_property(), text)
		_updating = false

func _can_handle(object: Object):
	return object is DataflowFunction or object is DataflowGraph

func _parse_property(object: Object, type: Variant.Type, name: String,
		hint_type: PropertyHint, hint_string: String,
		usage_flags: PropertyUsageFlags, wide: bool):
	if object is DataflowFunction:
		var array_property_preset = null
		if object._inputs_array_property_preset.element_property_name_matches(name, true):
			array_property_preset = object._inputs_array_property_preset
		elif object._outputs_array_property_preset.element_property_name_matches(name, true):
			array_property_preset = object._outputs_array_property_preset
		if array_property_preset != null:
			var index = array_property_preset.get_index_from_element_property_name(name, true)
			var subproperty = array_property_preset.get_subproperty_from_element_property_name(name)
			if subproperty == "identifier":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					array_property_preset.get_element_property_name(index, "generated_identifier")
				)
				add_property_editor(name, editor_property)
				return true
			if subproperty == "display_name":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					array_property_preset.get_element_property_name(index, "generated_display_name")
				)
				add_property_editor(name, editor_property)
				return true
	if object is DataflowGraph:
		var array_property_preset = null
		if object._nodes_array_property_preset.element_property_name_matches(name, true):
			array_property_preset = object._nodes_array_property_preset
		if array_property_preset != null:
			var index = array_property_preset.get_index_from_element_property_name(name, true)
			var subproperty = array_property_preset.get_subproperty_from_element_property_name(name)
			if subproperty == "identifier":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					array_property_preset.get_element_property_name(index, "generated_identifier")
				)
				add_property_editor(name, editor_property)
				return true
			if subproperty == "display_name":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					array_property_preset.get_element_property_name(index, "generated_display_name")
				)
				add_property_editor(name, editor_property)
				return true
	return false

