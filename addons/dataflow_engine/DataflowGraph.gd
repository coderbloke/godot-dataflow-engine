@icon("Dataflow.svg")
@tool
class_name DataflowGraph extends Resource

const DataflowNode = preload("DataflowNode.gd")

var nodes: Array[DataflowNode] = []

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "node_count",
		"class_name": "Nodes,node_,add_button_text=Add Node,page_size=10",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	for i in nodes.size():
		if nodes[i] == null:
			nodes[i] = DataflowNode.new()
		for p in nodes[i].get_property_list():
			p = p.duplicate()
			if p.usage & PROPERTY_USAGE_CATEGORY:
				continue
			if p.name in ["script"]:
				p.usage = p.usage & (~PROPERTY_USAGE_EDITOR)
			if p.name in ["title", "position"]:
				p.name = "visuals/" + p.name
			p.name = "node_%s/%s" % [i, p.name]
			properties.append(p)
	return properties

func _set(property: StringName, value: Variant):
	print("[DataflowGraph._set] %s = %s" % [property, value])
	if property == "node_count":
		if value != nodes.size():
			nodes.resize(value)
			property_list_changed.emit()
	elif property.begins_with("node_"):
		var slash_pos = property.find("/")
		var i := property.substr(0, slash_pos).get_slice("_", 1).to_int()
		if nodes[i] == null:
			nodes[i] = DataflowNode.new()
		property = property.substr(slash_pos + 1)
		for prefix in ["visuals/"]:
			property = property.trim_prefix(prefix)
		nodes[i].set(property, value)

func _get(property: StringName) -> Variant:
	if property == "node_count":
		return nodes.size()
	elif property.begins_with("node_"):
		var slash_pos = property.find("/")
		var i := property.substr(0, slash_pos).get_slice("_", 1).to_int()
		if nodes[i] == null:
			nodes[i] = DataflowNode.new()
		property = property.substr(slash_pos + 1)
		for prefix in ["visuals/"]:
			property = property.trim_prefix(prefix)
		return nodes[i].get(property)
	return null

