extends Node

# Properties
# |===================================|
# |===================================|
# |===================================|

var _signal_graph: SignalGraph
var _lambda_map: Dictionary = {}
var _signal_log: Array = []
var _signal_sequence: int = 0
var _is_signal_log_flush_queued: bool = false

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _ready():
	if OS.is_debug_build():
		EngineDebugger.register_message_capture("signal_debugger", _on_signal_debugger_message_capture)

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_signal_debugger_message_capture(message: String, data: Array) -> bool:
	if message == "start":
		_stop_signal_debugging()
		_signal_graph = generate_signal_graph()
		for signal_item in _signal_graph.signals:
			_connect_to_signal(signal_item)
		EngineDebugger.send_message(
			"signal_debugger:generated_graph",
			[[_signal_graph.signals.map(func (item): return item.dictionary_representation), _signal_graph.edges.map(func (item): return item.dictionary_representation)]]
		)
	if message == "stop" and _signal_graph:
		_stop_signal_debugging()

	return true

func _on_signal_execution(signal_name: String, node_name: String, args):
	_signal_log.append({
		"sequence": _signal_sequence,
		"time": Time.get_datetime_string_from_system(),
		"node_name": node_name,
		"signal_name": signal_name,
	})
	_signal_sequence += 1

	if not _is_signal_log_flush_queued:
		_is_signal_log_flush_queued = true
		call_deferred("_flush_signal_log")

# Methods
# |===================================|
# |===================================|
# |===================================|

func generate_signal_graph() -> SignalGraph:
	var graph = SignalGraphUtility.create_signal_graph_from_node(get_tree().current_scene, false, true)
	return graph

func _connect_to_signal(signal_item: SignalDescription):
	var _execute: Callable = func (args = []): _on_signal_execution(signal_item.signal_name, signal_item.node_name, args)
	var node = _find_node(signal_item.node_name)
	if node:
		if node.is_connected(signal_item.signal_name, _execute):
			return

		node.connect(signal_item.signal_name, _execute)
		_lambda_map[signal_item] = _execute

func _disconnect_from_signal(signal_item: SignalDescription):
	var node = _find_node(signal_item.node_name)
	var callable = _lambda_map.get(signal_item)
	if node and callable and node.is_connected(signal_item.signal_name, callable):
		node.disconnect(signal_item.signal_name, callable)
		_lambda_map.erase(signal_item)

func _stop_signal_debugging():
	if _signal_graph:
		for signal_item in _signal_graph.signals:
			_disconnect_from_signal(signal_item)
	_signal_graph = null
	_lambda_map.clear()
	_signal_log.clear()
	_is_signal_log_flush_queued = false

func _flush_signal_log():
	_is_signal_log_flush_queued = false
	if _signal_log.is_empty():
		return

	var signal_log = _signal_log.duplicate()
	_signal_log.clear()
	EngineDebugger.send_message("signal_debugger:signals_executed", [signal_log])

func _find_node(node_name: String) -> Node:
	var root_node = get_tree().current_scene
	if root_node.name == node_name:
		return root_node

	var child = root_node.find_child(node_name)
	if child:
		return child

	return get_tree().root.get_node_or_null(node_name)
