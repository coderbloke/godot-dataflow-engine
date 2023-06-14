@tool
extends RefCounted

## Array of Dictionaries
## Dictionaries shall have:
## - "signal_name": Name of the signal
## - "callable": The callback to connect to the signal
## - "object_class": The class of the object to connect. Can be String or GDNativeClass for built-in type, or Script
var _signals_to_connect: Array[Dictionary] = []

func add_signal_to_connect(signal_name: StringName, callable: Callable, object_class: Variant = null):
	if object_class != null \
			and not object_class is String \
			and not object_class is Script:
		printerr("Parameter 'object_class' must be String or Script. (add_signal_to_connect @ %s)" % self.get_script().resource_path)
		return
	_signals_to_connect.append({
		"signal_name": signal_name, 
		"callable": callable,
		"object_class": object_class,
	})
	
static func _is_object_of_class(object: Object, object_class: Variant):
	if object_class == null:
		return true
	if object_class is String:
		return ClassDB.is_parent_class(object.get_class(), object_class)
	if object_class is Script:
		var s := object.get_script() as Script
		while s != null:
			if s == object_class:
				return true
			s = s.get_base_script()
		return false
	return false

func connect_to_child(child: Object):
	for s in _signals_to_connect:
		if _is_object_of_class(child, s["object_class"]):
			child.connect(s["signal_name"], s["callable"])

func connect_to_children(children: Array):
	for child in children:
		connect_to_child(child)

func disconnect_from_child(child: Object):
	for s in _signals_to_connect:
		if _is_object_of_class(child, s["object_class"]): # Maybe this check is not needed here
			child.disconnect(s["signal_name"], s["callable"])

func disconnect_from_children(children: Array):
	for child in children:
		disconnect_from_child(child)

func update_child_connection(old_value: Object, new_value: Object) -> Object:
	if old_value != null:
		disconnect_from_child(old_value)
	if new_value != null:
		connect_to_child(new_value)
	return new_value

static func get_child_property_list(child, property_name_prefix: String = "") -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for p in child.get_property_list():
		p = p.duplicate()
		if not p.usage & PROPERTY_USAGE_STORAGE and not p.usage & PROPERTY_USAGE_EDITOR:
			continue
		if p.name in ["script"]:
			continue
		if not property_name_prefix.is_empty():
			p.name = property_name_prefix + p.name
		properties.append(p)
	return properties

func create_and_connect_if_necessary(object: Object, create_func: Callable) -> Object:
	if object == null:
		object = create_func.call()
		connect_to_child(object)
	return object


class ArrayPropertyPreset:
	
	var element_name: String
	var element_create_function: Callable
	var elements_changed_function: Callable
	var element_title: String
	var array_title: String
	
	func _init(element_name: String, element_create_function: Callable, elements_changed_function: Callable, element_title: String = "", array_title: String = ""):
		self.element_name = element_name
		self.element_create_function = element_create_function
		self.elements_changed_function = elements_changed_function
		self.element_title = element_title
		self.array_title = array_title

	func get_array_counter_property_name() -> String:
		return element_name + "_count"
	
	func get_element_property_name_prefix() -> String:
		return element_name + "_"
	
	func get_element_property_name(index: int) -> String:
		return "%s_%s" % [element_name, index]
	
	func get_index_from_element_property_name(property_name: String) -> int:
		return property_name.get_slice("_", 1).to_int()
	
	func get_element_title() -> String:
		if element_title != null and not element_title.is_empty():
			return element_title
		else:
			return element_name.capitalize()

	func get_array_title() -> String:
		if array_title != null and not array_title.is_empty():
			return array_title
		else:
			return get_element_title() + "s"

func get_array_property_list(array: Array, preset: ArrayPropertyPreset) -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": preset.get_array_counter_property_name(),
		"class_name": "%s,%s,add_button_text=Add %s,page_size=10" % [preset.get_array_title(), preset.get_element_property_name_prefix(), preset.get_element_title()],
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	for i in array.size():
		array[i] = create_and_connect_if_necessary(array[i], preset.element_create_function)
		properties.append_array(get_child_property_list(array[i], preset.get_element_property_name(i) + "/"))
	return properties

func is_array_property(property: StringName, preset: ArrayPropertyPreset, ) -> bool:
	if property == preset.get_array_counter_property_name():
		return true
	elif property.begins_with(preset.get_element_property_name_prefix()):
		return true
	return false

func set_array_property(property: StringName, value: Variant, array: Array, preset: ArrayPropertyPreset):
	if property == preset.get_array_counter_property_name():
		if value != array.size():
			array.resize(value)
			preset.elements_changed_function.call()
	elif property.begins_with(preset.get_element_property_name_prefix()):
		var slash_pos = property.find("/")
		var i := preset.get_index_from_element_property_name(property.substr(0, slash_pos))
		array[i] = create_and_connect_if_necessary(array[i], preset.element_create_function)
		array[i].set(property.substr(slash_pos + 1), value)

func get_array_property(property: StringName, array: Array, preset: ArrayPropertyPreset) -> Variant:
	if property == preset.get_array_counter_property_name():
		return array.size()
	elif property.begins_with(preset.get_element_property_name_prefix()):
		var slash_pos = property.find("/")
		var i := preset.get_index_from_element_property_name(property.substr(0, slash_pos))
		array[i] = create_and_connect_if_necessary(array[i], preset.element_create_function)
		return array[i].get(property.substr(slash_pos + 1))
	return null

