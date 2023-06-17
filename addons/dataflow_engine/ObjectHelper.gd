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
	
	func property_name_matches(property_name: String) -> bool:
		var parts := property_name.split("_")
		return parts[0] == element_name and parts[1].is_valid_int()
	
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
			var  previous_size := array.size()
			array.resize(value)
			for i in array.size():
				if i >= previous_size:
					array[i] = create_and_connect_if_necessary(array[i], preset.element_create_function)
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

static func generate_display_name(identififer: String) -> String:
	if identififer.is_empty():
		return ""
	var previous_char_was_space := false
	var display_name =  identififer.to_snake_case().replace("_", " ")
	display_name = display_name[0].capitalize() + display_name.substr(1)
	return display_name

static func generate_identifier(display_name: String) -> String:
	return display_name.to_snake_case()

static func to_suitable_id(identifier: String) -> String:
	var suitable_id = ""
	for c in identifier:
		if c == "_" or (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= 'A' and c <= "Z"):
			suitable_id += c
	return suitable_id

class ChildIdentifierPreset:
	
	var default_identifier_base: String
	var getter: Callable
	
	func _init(default_identifier_base: String, getter: Callable):
		self.default_identifier_base = default_identifier_base
		self.getter = getter

static func generate_child_identifiers(children: Array, preset: ChildIdentifierPreset, triggering_child: Object = null) -> Dictionary:
#	var log = DebugInfo.get_log("Object Helper") # DEBUG
#	log.clear() # DEBUG
	
	var children_per_id_base = { } # String -> Object
	var id_base_per_child = { } # Object -> String
	var id_index_per_child = { } # Object -> int

	var requested_id_base := ""
	var requested_id_index := -1

	if triggering_child not in children:
		children = children.duplicate()
		children.append(triggering_child)
		
	var index_base = 1 # Could be 0 also, but 1 is more human

	for child in children:
		if child == null:
			continue
		var child_id_base := preset.getter.call(child)
		if child_id_base == null or child_id_base.is_empty():
			child_id_base = preset.default_identifier_base
		var child_id_index := -1
		var last_underscore = child_id_base.rfind("_")
		if last_underscore >= 0 and child_id_base.substr(last_underscore + 1).is_valid_int():
			child_id_index = child_id_base.substr(last_underscore).to_int()
			child_id_base = child_id_base.substr(0, last_underscore)
		
		if children_per_id_base.get(child_id_base) == null:
			children_per_id_base[child_id_base] = []
		children_per_id_base[child_id_base].append(child)
			
#		log.print_colored(Color.DARK_GRAY, "[generate_child_identifiers] base = %s, index = %s (%s)" % [child_id_base, child_id_index, child]) # DEBUG
		
		id_base_per_child[child] = child_id_base
		id_index_per_child[child] = child_id_index
		
		if child == triggering_child:
			requested_id_base = child_id_base
			requested_id_index = child_id_index
	
	# Give new id to the children, if needed
	var new_id_per_child = { } # Object -> String
	
	if children_per_id_base.size() == 0:
		return new_id_per_child # Nothing to do (e.g.during init, when array is empty or nfilled with nulls yet
	
	for id_base in children_per_id_base:
#		log.print_colored(Color.LIGHT_GREEN, "[generate_child_identifiers] id_base = %s" % [id_base]) # DEBUG
		# Save a bit of computation, if triggering child does not bother the whole list
		# (But skipped, as in this case it won't remove unnecessary indices)
#		if triggering_child != null and id_base != requested_id_base: 
#			continue
		
		# Trigger child, so which took an index the last time, should keep it, and other should get new one
		# Otherwise everybody can keep it previous index
		# We also remove duplicates
		var already_used_id_indices = PackedInt64Array()  # Keep it sorted, to find first unused one
		for child in children_per_id_base[id_base]:
			if child != triggering_child and id_index_per_child[child] == requested_id_index:
				id_index_per_child[child] = -1
#				log.print_colored(Color.DARK_GRAY, "id lost as its requested by trigger (looser = %s)" % child)
			if id_index_per_child[child] >= index_base:
				if id_index_per_child[child] in already_used_id_indices:
					id_index_per_child[child] = -1
#					log.print_colored(Color.DARK_GRAY, "id lost as duplicate (duplicate = %s)" % child)
				else:
					already_used_id_indices.append(id_index_per_child[child])
		already_used_id_indices.sort() # Keep it sorted, to find first unused one
#		log.print("[generate_child_identifiers] already_used_id_indices = %s" % [already_used_id_indices]) # DEBUG
		
		# Get new index for children, if it has no index (did not haveor lost)
		for child in children_per_id_base[id_base]:
#			log.print("[generate_child_identifiers] child = %s, index = %s" % [child, id_index_per_child[child]]) # DEBUG
			# No index needed, if there is only one child in the group
			if children_per_id_base[id_base].size() < 2:
				# Needs change, if previously it had index
				if id_index_per_child[child] >= index_base:
					new_id_per_child[child] = id_base
#				log.print("[generate_child_identifiers] no need for index -> new_id_per_child = %s" % [new_id_per_child]) # DEBUG
				continue
			
			# Child has an index, and it has not been removed, so it's ok
			if id_index_per_child[child] >= index_base:
#				log.print("[generate_child_identifiers] keeping index -> new_id_per_child = %s" % [new_id_per_child]) # DEBUG
				continue
			
			# If child needs index
			if id_index_per_child[child] < index_base:
				# Search for the smallest unused index
				var last_used_index = index_base - 1
				var unused_index = -1
				var insert_position = -1
				for i in already_used_id_indices.size():
					if already_used_id_indices[i] > last_used_index + 1:
						unused_index = last_used_index + 1
						insert_position = i
						break
					last_used_index = already_used_id_indices[i]
					
#				log.print("[generate_child_identifiers] unused_index = %s, insert_position = %s" % [unused_index, insert_position]) # DEBUG
				if unused_index >= index_base:
					# We found a gap in the list of already used id, so insert a new one
					already_used_id_indices.insert(insert_position, unused_index)
				else:
					# Otherwise simply get the next on
					unused_index = last_used_index + 1 if last_used_index >= index_base else index_base
					already_used_id_indices.append(unused_index)
#				log.print("[generate_child_identifiers] got new index -> already_used_id_indices = %s" % [already_used_id_indices]) # DEBUG
				# Give it tho the child
				new_id_per_child[child] = id_base + "_" + str(unused_index)
#				log.print("[generate_child_identifiers] got new index -> new_id_per_child = %s" % [new_id_per_child]) # DEBUG
				continue
	
	return new_id_per_child
	
