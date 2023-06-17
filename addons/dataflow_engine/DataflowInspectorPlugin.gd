@tool
extends EditorInspectorPlugin

class PropertyLineEdit extends EditorProperty:

	var _update_trigger: Signal
	var _placeholder_property: String
	
	var _line_edit: LineEdit
	var _updating := false
	
	func _init(placeholder_property: String, update_trigger: Signal = Signal()):
		update_trigger = Signal()
		self._update_trigger = update_trigger
		self._placeholder_property = placeholder_property
		_line_edit = LineEdit.new()
		if not _update_trigger.is_null():
			_update_trigger.connect(update_line_edit)
		_line_edit.text_changed.connect(_on_text_changed)
		_line_edit.focus_exited.connect(update_line_edit)
		add_child(_line_edit)
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			if not _update_trigger.is_null():
				_update_trigger.disconnect(update_line_edit)

	func _update_property():
		update_line_edit()

	func update_line_edit():
		var placeholder_text = get_edited_object().get(_placeholder_property)
		if placeholder_text != _line_edit.placeholder_text:
			_line_edit.placeholder_text = placeholder_text
		var caret = _line_edit.caret_column
		var text = get_edited_object().get(get_edited_property())
		if text != _line_edit.text:
			_line_edit.text = text if text else ""
			_line_edit.caret_column = caret

	func _on_text_changed(text: String):
		_updating = true
		emit_changed(get_edited_property(), text)
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
				var placeholder_property = array_property_preset.get_element_property_name(index, "generated_identifier")
				var property_editor := PropertyLineEdit.new(
					placeholder_property,
					object.changed,
				)
				add_property_editor(name, property_editor)
				return true
			if subproperty == "display_name":
				var placeholder_property = array_property_preset.get_element_property_name(index, "generated_display_name")
				var property_editor := PropertyLineEdit.new(
					placeholder_property,
					object.changed,
				)
				add_property_editor(name, property_editor)
				return true
			if subproperty == "generated_identifier":
				# Do not include separate editor for this, as it is presented in identifier's editor
				return true
			if subproperty == "generated_display_name":
				# Do not include separate editor for this, as it is presented in display_name's editor
				return true
	if object is DataflowGraph:
		var array_property_preset = null
		if object._nodes_array_property_preset.element_property_name_matches(name, true):
			array_property_preset = object._nodes_array_property_preset
		if array_property_preset != null:
			var index = array_property_preset.get_index_from_element_property_name(name, true)
			var subproperty = array_property_preset.get_subproperty_from_element_property_name(name)
			if subproperty == "identifier":
				var placeholder_property = array_property_preset.get_element_property_name(index, "generated_identifier")
				var property_editor := PropertyLineEdit.new(
					placeholder_property,
					object.changed,
				)
				add_property_editor(name, property_editor)
				return true
			if subproperty == "display_name":
				var placeholder_property = array_property_preset.get_element_property_name(index, "generated_display_name")
				var property_editor := PropertyLineEdit.new(
					placeholder_property,
					object.changed,
				)
				add_property_editor(name, property_editor)
				return true
			if subproperty == "generated_identifier":
				# Do not include separate editor for this, as it is presented in identifier's editor
				return true
			if subproperty == "generated_display_name":
				# Do not include separate editor for this, as it is presented in display_name's editor
				return true
	return false

