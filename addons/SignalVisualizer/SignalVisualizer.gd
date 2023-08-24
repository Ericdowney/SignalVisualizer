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



# Methods
# |===================================|
# |===================================|
# |===================================|

