@tool
extends EditorInspectorPlugin

class PropertyLineEdit extends EditorProperty:

	var update_trigger: Signal
	var placeholder_getter: Callable
	var text_getter: Callable
	var property_setter: Callable
	
	var line_edit: LineEdit
	var _updating := false
	
	func _init(update_trigger: Signal, placeholder_getter: Callable, text_getter: Callable, property_setter: Callable):
		self.update_trigger = update_trigger
		self.placeholder_getter = placeholder_getter
		self.text_getter = text_getter
		self.property_setter = property_setter
		line_edit = LineEdit.new()
		update_line_edit()
		update_trigger.connect(update_line_edit)
		line_edit.text_changed.connect(_on_text_changed)
		add_child(line_edit)
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			update_trigger.disconnect(update_line_edit)

	func update_line_edit():
		if not _updating:
			line_edit.placeholder_text = placeholder_getter.call()
			line_edit.text = text_getter.call()

	func _on_text_changed(text: String):
		_updating = true
		property_setter.call(text)
		_updating = false

func _can_handle(object: Object):
	return object is DataflowFunction

func _parse_property(object: Object, type: Variant.Type, name: String,
		hint_type: PropertyHint, hint_string: String,
		usage_flags: PropertyUsageFlags, wide: bool):
	if object is DataflowFunction:
		var name_parts = name.split("/")
		var function_parameter: DataflowFunction.DataflowFunctionParameter = null
		if name_parts.size() == 2 and object._inputs_array_property_preset.property_name_matches(name_parts[0]):
			var index = object._inputs_array_property_preset.get_index_from_element_property_name(name_parts[0])
			function_parameter = object._inputs[index]
		elif name_parts.size() == 2 and object._outputs_array_property_preset.property_name_matches(name_parts[0]):
			var index = object._outputs_array_property_preset.get_index_from_element_property_name(name_parts[0])
			function_parameter = object._outputs[index]
		if function_parameter != null:
			if name_parts[1] == "identifier":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					func(): return function_parameter.generated_identifier,
					func(): return function_parameter.identifier,
					func(value): function_parameter.identifier = value,
				)
				add_property_editor(name, editor_property)
				return true
			if name_parts[1] == "display_name":
				var editor_property := PropertyLineEdit.new(
					object.changed,
					func(): return function_parameter.generated_display_name,
					func(): return function_parameter.display_name,
					func(value): function_parameter.display_name = value,
				)
				add_property_editor(name, editor_property)
				return true
	return false

