@tool
extends Node

enum ConnectionType { incoming, outgoing }

# Properties
# |===================================|
# |===================================|
# |===================================|



# Lifecycle
# |===================================|
# |===================================|
# |===================================|



# Signals
# |===================================|
# |===================================|
# |===================================|



# Methods
# |===================================|
# |===================================|
# |===================================|

func generate_signal_graph(is_persistent_only: bool = true) -> SignalGraph:
	var signal_graph = SignalGraph.new()
	var all_nodes: Array[Node] = gather_nodes_in_scene()
	var all_active_signals: Array[SignalDescription] = []
	
	signal_graph.name = get_tree().edited_scene_root.scene_file_path
	
	for node in all_nodes:
		for signal_item in node.get_signal_list():
			var connection_list = node.get_signal_connection_list(signal_item["name"] as String)
			if connection_list.size() > 0:
				var connections = []
				for connection in connection_list:
					var enabled_flags = connection["flags"] == CONNECT_PERSIST if is_persistent_only else true
					var should_display_connection = "name" in connection["callable"].get_object() and not connection["callable"].get_object().name.begins_with("@") and enabled_flags
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

func gather_nodes_in_scene() -> Array[Node]:
	var scene_root = get_tree().edited_scene_root
	var node_list: Array[Node] = [scene_root]
	return node_list + _gather_nodes_from_node(scene_root)

func _gather_nodes_from_node(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(false):
		nodes.append(child)
		nodes += _gather_nodes_from_node(child)
	
	return nodes
