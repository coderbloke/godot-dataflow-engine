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
