@tool
class_name SignalGraphUtility

static var SignalGraphNode = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node.tscn")
static var GraphNodeItem = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node_item.tscn")

const SOURCE_COLOR: Color = Color.SKY_BLUE
const DESTINATION_COLOR: Color = Color.CORAL
const CONNECTION_TYPE: int = 0

#region Methods

static func create_signal_graph(name: String, signals: Array, edges: Array) -> SignalGraph:
	var signal_graph = SignalGraph.new(name)
	
	for signal_item in signals:
		var new_signal_description = SignalDescription.new(signal_item.node_name, signal_item.signal_name)
		new_signal_description._source_id = signal_item.id
		signal_graph.signals.append(new_signal_description)
		
		for connection in edges:
			var new_edge = SignalConnection.new(connection.signal_id, connection.source_node_name, connection.destination_node_name, connection.method_signature)
			signal_graph.edges.append(new_edge)
	
	return signal_graph

static func create_signal_graph_from_node(root_node: Node, is_persistent_only: bool = false):
	var signal_graph = SignalGraph.new(root_node.scene_file_path)
	var all_nodes: Array[Node] = _gather_nodes_from_node(root_node)
	var signals: Array[SignalDescription] = []
	var edges: Array[SignalConnection] = []
	
	for node in all_nodes:
		for signal_item in node.get_signal_list():
			var existing_signals = []
			var connection_list = node.get_signal_connection_list(signal_item["name"] as String)
			if connection_list.size() > 0:
				for connection in connection_list:
					var enabled_flags = connection["flags"] == CONNECT_PERSIST if is_persistent_only else true
					var should_display_connection = "name" in connection["callable"].get_object() and not connection["callable"].get_object().name.begins_with("@") and enabled_flags
					if should_display_connection:
						var signal_description: SignalDescription
						var filtered_signals = existing_signals.filter(func (element): return element.signal_name == signal_item.name and element.node_name == node.name)
						if filtered_signals.size() == 1:
							signal_description = filtered_signals[0]
						else:
							signal_description = SignalDescription.new(node.name, signal_item.name)
							existing_signals.append(signal_description)
							signals.append(signal_description)
						
						var signal_edge = SignalConnection.new(signal_description.id, signal_description.node_name, connection["callable"].get_object().name, connection["callable"].get_method())
						if not signal_graph.edges.any(func (element): return element.signal_id == signal_description.id):
							edges.append(signal_edge)
	
	var temp_signals = {}
	for item in signals:
		temp_signals[item.id] = item
	
	var temp_edges = {}
	for item in edges:
		temp_edges[item.dictionary_key] = item
	
	signal_graph.signals.assign(temp_signals.keys().map(func (key): return temp_signals[key]))
	signal_graph.edges.assign(temp_edges.keys().map(func (key): return temp_edges[key]))
	
	return signal_graph

static func generate_signal_graph_nodes(signal_graph: SignalGraph, graph_node: GraphEdit, open_script_callable: Callable):
	var graph_nodes: Dictionary = {}
	
	for signal_item in signal_graph.signals:
		var current_graph_node: SignalGraphNode
		if graph_nodes.has(signal_item.node_name):
			current_graph_node = graph_nodes[signal_item.node_name]
		if not current_graph_node:
			current_graph_node = SignalGraphNode.instantiate()
			current_graph_node.title = signal_item.node_name
			current_graph_node.name = _get_graph_node_name(signal_item.node_name)
			graph_node.add_child(current_graph_node)
			graph_nodes[signal_item.node_name] = current_graph_node
	
	for edge in signal_graph.edges:
		var destination_graph_node: SignalGraphNode
		if graph_nodes.has(edge.destination_node_name):
			destination_graph_node = graph_nodes[edge.destination_node_name]
		else:
			destination_graph_node = SignalGraphNode.instantiate()
			destination_graph_node.title = edge.destination_node_name
			destination_graph_node.name = _get_graph_node_name(edge.destination_node_name)
			graph_node.add_child(destination_graph_node)
			graph_nodes[edge.destination_node_name] = destination_graph_node
		
		var source_signal = signal_graph.get_source_signal_for_edge(edge)
		if source_signal != null:
			var source_graph_node: SignalGraphNode = graph_nodes[edge.source_node_name] as SignalGraphNode
			
			if not source_graph_node.has_source_signal_description(source_signal.signal_name, edge.destination_node_name):
				var source_signal_label = Label.new()
				source_signal_label.text = source_signal.signal_name
				source_signal_label.name = "source_" + source_signal.signal_name + "_" + edge.destination_node_name
				source_graph_node.add_child(source_signal_label)
			
			var destination_signal_name = "destination_" + source_signal.signal_name + "_" + edge.method_signature.replace("::", "__")
			var has_destination = destination_graph_node.has_destination_signal_description(source_signal.signal_name, edge.method_signature)
			if not has_destination:
				var destination_signal_item = GraphNodeItem.instantiate()
				destination_signal_item.signal_data = SignalGraphNodeItem.Metadata.new(source_signal.signal_name, edge.method_signature, edge.destination_node_name)
				destination_signal_item.text = edge.method_signature
				destination_signal_item.name = destination_signal_name
				destination_signal_item.open_script.connect(open_script_callable)
				destination_graph_node.add_child(destination_signal_item)
	
	for edge in signal_graph.edges:
		var source_signal = signal_graph.get_source_signal_for_edge(edge)
		if source_signal != null:
			var source_graph_node: SignalGraphNode = graph_nodes[edge.source_node_name] as SignalGraphNode
			var destination_graph_node: SignalGraphNode = graph_nodes[edge.destination_node_name] as SignalGraphNode
			
			var from_port = source_graph_node.get_source_slot(source_signal.signal_name, edge.destination_node_name)
			var to_port = destination_graph_node.get_destination_slot(source_signal.signal_name, edge.method_signature)
			
			source_graph_node.set_slot(from_port, false, CONNECTION_TYPE, Color.BLACK, true, CONNECTION_TYPE, SOURCE_COLOR)
			destination_graph_node.set_slot(to_port, true, CONNECTION_TYPE, DESTINATION_COLOR, false, CONNECTION_TYPE, Color.BLACK)
			
			var from_slot_index = source_graph_node.get_next_source_slot(source_signal.signal_name, edge.destination_node_name)
			var to_slot_index = destination_graph_node.get_next_destination_slot(source_signal.signal_name, edge.method_signature)
			
			if from_port >= 0 and to_port >= 0:
				graph_node.connect_node(source_graph_node.name, from_slot_index, destination_graph_node.name, to_slot_index)
			else:
				print(">>> Invalid Connection Request")

static func generate_signal_graph_tree(signal_graph: SignalGraph, tree_node: Tree):
	var root = tree_node.create_item()
	root.set_text(0, signal_graph.name)
	
	var tree_items: Dictionary = {}
	
	for signal_item in signal_graph.signals:
		var node_tree_item: TreeItem
		if tree_items.has(signal_item.node_name):
			node_tree_item = tree_items[signal_item.node_name] as TreeItem
		else:
			node_tree_item = tree_node.create_item(root)
			node_tree_item.set_text(0, signal_item.node_name)
			tree_items[signal_item.node_name] = node_tree_item
		
		var signal_tree_item = tree_node.create_item(node_tree_item)
		signal_tree_item.set_text(0, signal_item.signal_name)
			
		for edge in signal_graph.edges.filter(func (item): return item.signal_id == signal_item.id):
			var signal_connection_tree_item = tree_node.create_item(signal_tree_item)
			signal_connection_tree_item.set_text(0, edge.destination_node_name + "::" + edge.method_signature)

static func _get_graph_node_name(name: String) -> String:
	return "{node_name}_graph_node".format({ "node_name": name })

static func _gather_nodes_from_node(root_node: Node) -> Array[Node]:
	var node_list: Array[Node] = [root_node]
	return node_list + __gather_nodes_from_node(root_node)

static func __gather_nodes_from_node(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(false):
		nodes.append(child)
		nodes += __gather_nodes_from_node(child)
	
	return nodes

#endregion
