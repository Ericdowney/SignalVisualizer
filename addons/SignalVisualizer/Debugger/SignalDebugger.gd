extends Node

# Properties
# |===================================|
# |===================================|
# |===================================|

var _signal_graph: SignalGraph
var _lambda_map: Dictionary = {}

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
		_signal_graph = generate_signal_graph()
		for signal_item in _signal_graph.signals:
			_connect_to_signal(signal_item)
		EngineDebugger.send_message(
			"signal_debugger:generated_graph",
			[_signal_graph.signals.map(func (item): return item.dictionary_representation)]
		)
	if message == "stop" and _signal_graph:
		for signal_item in _signal_graph.signals:
			_disconnect_from_signal(signal_item)
	
	if message == "invoke_signal" and data.size() == 2:
		var node_name = data[0]
		var signal_name = data[1]
		
		var root_node = get_tree().current_scene
		var node = root_node if root_node.name == node_name else root_node.find_child(node_name)
		if node:
			var connection_list = node.get_signal_connection_list(signal_name)
			for connection in connection_list:
				var callable = connection["callable"]
				var bound_args = callable.get_bound_arguments()
				var bound_args_count = callable.get_bound_arguments_count()
				var method = callable.get_method()
				callable.callv([node])
	
	return true

func _on_signal_execution(signal_name: String, node_name: String, args):
	EngineDebugger.send_message(
		"signal_debugger:signal_executed",
		[Time.get_datetime_string_from_system(), node_name, signal_name]
	)

# Methods
# |===================================|
# |===================================|
# |===================================|

func generate_signal_graph(is_persistent_only: bool = true) -> SignalGraph:
	var signal_graph = SignalGraph.new()
	var all_nodes: Array[Node] = _gather_nodes_in_scene()
	var all_active_signals: Array[SignalDescription] = []
	
	signal_graph.name = get_tree().current_scene.name
	
	for node in all_nodes:
		for signal_item in node.get_signal_list():
			var connection_list = node.get_signal_connection_list(signal_item["name"] as String)
			if connection_list.size() > 0:
				var connections = []
				for connection in connection_list:
					var enabled_flags = connection["flags"] != CONNECT_ONE_SHOT if is_persistent_only else true
					var should_display_connection = "name" in connection["callable"].get_object() and not connection["callable"].get_object().name.begins_with("@")# and enabled_flags
					if should_display_connection:
						var new_signal_description = SignalDescription.new()
						new_signal_description.node_name = node.name
						new_signal_description.signal_name = connection["signal"].get_name()
						signal_graph.signals.append(new_signal_description)
						
						var new_edge = SignalConnection.new()
						new_edge.signal_id = new_signal_description.id
						new_edge.source_node_name = new_signal_description.node_name
						new_edge.destination_node_name = connection["callable"].get_object().name
						new_edge.method_signature = connection["callable"].get_method()
						signal_graph.edges.append(new_edge)
	
	return signal_graph

func _gather_nodes_in_scene() -> Array[Node]:
	var scene_root = get_tree().current_scene
	var node_list: Array[Node] = [scene_root]
	return node_list + _gather_nodes_from_node(scene_root)

func _gather_nodes_from_node(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(false):
		nodes.append(child)
		nodes += _gather_nodes_from_node(child)
	
	return nodes

func _connect_to_signal(signal_item: SignalDescription):
	var root_node = get_tree().current_scene
	var _execute: Callable = func (args): _on_signal_execution(signal_item.signal_name, signal_item.node_name, args)
	if root_node.name == signal_item.node_name:
		root_node.connect(signal_item.signal_name, _execute)
		_lambda_map[signal_item] = _execute
	else:
		var child = root_node.find_child(signal_item.node_name)
		if child:
			child.connect(signal_item.signal_name, _execute)
			_lambda_map[signal_item] = _execute

func _disconnect_from_signal(signal_item: SignalDescription):
	var root_node = get_tree().current_scene
	if root_node.name == signal_item.node_name:
		var callable = _lambda_map[signal_item]
		if callable:
			root_node.disconnect(signal_item.signal_name, callable)
			_lambda_map.erase(signal_item)
	else:
		var child = root_node.find_child(signal_item.node_name)
		if child:
			var callable = _lambda_map[signal_item]
			if callable:
				child.disconnect(signal_item.signal_name, callable)
				_lambda_map.erase(signal_item)
