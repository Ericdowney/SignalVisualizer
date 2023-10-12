@tool
extends EditorPlugin

class SignalDebuggerPlugin extends EditorDebuggerPlugin:
	var SignalDebuggerPanelScene = preload("res://addons/SignalVisualizer/Debugger/SignalDebugger.tscn")
	
	signal start_signal_debugging
	signal stop_signal_debugging
	
	var debugger_panel: SignalDebuggerPanel
	
	func _has_capture(prefix):
		return prefix == "signal_debugger"
	
	func _capture(message, data, session_id):
		if message == "signal_debugger:signal_executed":
			if data.size() == 3:
				var time = data[0]
				var node_name = data[1]
				var signal_name = data[2]
				debugger_panel.log_signal_execution(time, node_name, signal_name)
				return true
		
		if message == "signal_debugger:generated_graph":
			if data.size() == 1:
				var signals = data[0] as Array
				debugger_panel.create_tree_from_signals(signals)
				return true
		
		return false
	
	func _setup_session(session_id):
		debugger_panel = SignalDebuggerPanelScene.instantiate()
		var session = get_session(session_id)
		
		debugger_panel.name = "Signal Debugger"
		debugger_panel.start_signal_debugging.connect(func (): start_signal_debugging.emit())
		debugger_panel.stop_signal_debugging.connect(func (): stop_signal_debugging.emit())
		
		session.started.connect(
			func ():
				debugger_panel.enable()
		)
		session.stopped.connect(
			func ():
				debugger_panel.stop()
				debugger_panel.disable()
				stop_signal_debugging.emit()
		)
		
		session.add_session_tab(debugger_panel)

var SignalVisualizerDockScene = preload("res://addons/SignalVisualizer/Visualizer/signal_visualizer_dock.tscn")

class ScriptMethodReference:
	var script_reference: Script
	var line_number: int

# Properties
# |===================================|
# |===================================|
# |===================================|

var dock: Control
var debugger: SignalDebuggerPlugin

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _enter_tree():
	dock = SignalVisualizerDockScene.instantiate()
	debugger = SignalDebuggerPlugin.new()
	
	dock.open_script.connect(_on_open_signal_in_script)
	add_control_to_bottom_panel(dock, "Signal Visualizer")
	
	debugger.start_signal_debugging.connect(_on_debugger_start_signal_debugging)
	debugger.stop_signal_debugging.connect(_on_debugger_stop_signal_debugging)
	add_debugger_plugin(debugger)
	add_autoload_singleton("Signal_Debugger", "res://addons/SignalVisualizer/Debugger/SignalDebugger.gd")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.free()
	
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("Signal_Debugger")

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

func _on_debugger_start_signal_debugging():
	for session in debugger.get_sessions():
		if session.is_debuggable():
			session.send_message("signal_debugger:start", [])

func _on_debugger_stop_signal_debugging():
	for session in debugger.get_sessions():
		if session.is_debuggable():
			session.send_message("signal_debugger:stop", [])

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
