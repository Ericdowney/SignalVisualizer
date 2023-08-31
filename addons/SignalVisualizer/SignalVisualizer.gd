@tool
extends EditorPlugin

var Dock = preload("res://addons/SignalVisualizer/signal_visualizer_dock.tscn")

# Properties
# |===================================|
# |===================================|
# |===================================|

var dock: Control

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _enter_tree():
	dock = Dock.instantiate()
	dock.open_script.connect(_on_open_signal_in_script)
	add_control_to_bottom_panel(dock, "Signal Visualizer")
	
	add_autoload_singleton("SignalVisualizerManager", "res://addons/SignalVisualizer/signal_visualizer_manager.gd")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
	
	remove_autoload_singleton("SignalVisualizerManager")

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_open_signal_in_script(node_name: String, method_signature: String):
	var node: Node
	if get_tree().edited_scene_root.name == node_name:
		node = get_tree().edited_scene_root
	else:
		node = get_tree().edited_scene_root.find_child(node_name)
	
	var script: Script = node.get_script()
	var editor = get_editor_interface()
	var line_number = 0
	for line in script.source_code.split("\n", true):
		line_number += 1
		if line.contains(method_signature):
			break
	
	editor.edit_script(script, line_number, 0)
	editor.set_main_screen_editor("Script")

# Methods
# |===================================|
# |===================================|
# |===================================|


