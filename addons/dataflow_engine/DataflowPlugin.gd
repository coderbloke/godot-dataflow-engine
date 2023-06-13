@tool
extends EditorPlugin

var dataflow_editor: Node

func _enter_tree():
	dataflow_editor = preload("DataflowEditor.gd").new()
	dataflow_editor.editor_interface = get_editor_interface()
#	var main_screen := get_editor_interface().get_editor_main_screen()
#	main_screen.add_child(dataflow_editor)
	add_control_to_bottom_panel(dataflow_editor, "Dataflow Editor")


func _exit_tree():
#	get_editor_interface().get_editor_main_screen().remove_child(dataflow_editor)
	remove_control_from_bottom_panel(dataflow_editor)
	dataflow_editor.queue_free()


func _has_main_screen():
	#return true
	return false


func _make_visible(visible):
	if dataflow_editor:
		dataflow_editor.visible = visible


func _get_plugin_name():
	return "Dataflow"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return preload("Dataflow.svg")
