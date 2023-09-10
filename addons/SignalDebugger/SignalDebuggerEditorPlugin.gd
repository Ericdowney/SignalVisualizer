@tool
extends EditorPlugin

class SignalDebuggerPlugin extends EditorDebuggerPlugin:
	var SignalDebuggerScene = preload("res://addons/SignalDebugger/SignalDebugger.tscn")
	
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
		debugger_panel = SignalDebuggerScene.instantiate()
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

# Properties
# |===================================|
# |===================================|
# |===================================|

var debugger: SignalDebuggerPlugin = SignalDebuggerPlugin.new()

# Lifecycle
# |===================================|
# |===================================|
# |===================================|


func _enter_tree():
	debugger.start_signal_debugging.connect(_on_debugger_start_signal_debugging)
	add_debugger_plugin(debugger)
	add_autoload_singleton("Signal_Debugger", "res://addons/SignalDebugger/SignalDebugger.gd")

func _exit_tree():
	remove_debugger_plugin(debugger)
	remove_autoload_singleton("Signal_Debugger")

# Signals
# |===================================|
# |===================================|
# |===================================|

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


