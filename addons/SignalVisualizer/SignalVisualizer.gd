@tool
extends EditorPlugin

var Dock = preload("res://addons/SignalVisualizer/signal_visualizer_dock.tscn")

class ScriptMethodReference:
	var script_reference: Script
	var line_number: int

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

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()

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
	var method_reference = _find_method_reference_in_script(script, method_signature)
	
	editor.edit_script(method_reference.script_reference, method_reference.line_number, 0)
	editor.set_main_screen_editor("Script")

# Methods
# |===================================|
# |===================================|
# |===================================|

func _find_method_reference_in_script(script: Script, method_signature: String) -> ScriptMethodReference:
	var line_number = __find_method_line_number_in_script(script, method_signature)
	
	if line_number == -1:
		var base_script = script.get_base_script()
		if base_script:
			return _find_method_reference_in_script(base_script, method_signature)
	
	var reference = ScriptMethodReference.new()
	reference.script_reference = script
	reference.line_number = line_number
	
	return reference

func __find_method_line_number_in_script(script: Script, method_signature: String) -> int:
	var line_number = 0
	var found = false
	for line in script.source_code.split("\n", true):
		line_number += 1
		if line.contains(method_signature):
			found = true
			return line_number
	
	return -1
