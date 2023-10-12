@tool
extends Control

signal open_script(node_name: String, method_signature: String)

var SignalGraphNode = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node.tscn")
var GraphNodeItem = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node_item.tscn")

# Properties
# |===================================|
# |===================================|
# |===================================|

const SOURCE_COLOR: Color = Color.SKY_BLUE
const DESTINATION_COLOR: Color = Color.CORAL
const CONNECTION_TYPE: int = 0

@onready var arrange_nodes_checkbox: CheckBox = %ArrangeNodesCheckBox
@onready var signal_details_checkbox: CheckBox = %SignalDetailsCheckBox
@onready var signal_tree: Tree = %SignalTree
@onready var graph: GraphEdit = %Graph

# Lifecycle
# |===================================|
# |===================================|
# |===================================|



# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_clear_graph_button_pressed():
	clear()

func _on_generate_graph_button_pressed():
	clear()
	
	var scene_signal_graph = generate_signal_graph()
	_generate_signal_graph(scene_signal_graph)
	_generate_tree(scene_signal_graph)
	
	if arrange_nodes_checkbox.button_pressed:
		graph.arrange_nodes()

func _on_open_signal_in_script(data: SignalGraphNodeItem.Metadata):
	open_script.emit(data.node_name, data.method_signature)

# Methods
# |===================================|
# |===================================|
# |===================================|

func generate_signal_graph(is_persistent_only: bool = true) -> SignalGraph:
	var signal_graph = SignalGraph.new()
	var all_nodes: Array[Node] = _gather_nodes_in_scene()
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

func clear():
	_clear_graph_nodes()
	_clear_tree()

func _clear_graph_nodes():
	graph.clear_connections()
	for child in graph.get_children():
		if child is SignalGraphNode:
			child.queue_free()

func _clear_tree():
	signal_tree.clear()

func _generate_signal_graph(signal_graph: SignalGraph):
	var graph_nodes: Dictionary = {}
	
	for signal_item in signal_graph.signals:
		var current_graph_node: SignalGraphNode
		if graph_nodes.has(signal_item.node_name):
			current_graph_node = graph_nodes[signal_item.node_name]
		if not current_graph_node:
			current_graph_node = SignalGraphNode.instantiate()
			current_graph_node.title = signal_item.node_name
			current_graph_node.name = _get_graph_node_name(signal_item.node_name)
			graph.add_child(current_graph_node)
			graph_nodes[signal_item.node_name] = current_graph_node
	
	for edge in signal_graph.edges:
		var destination_graph_node: SignalGraphNode
		if graph_nodes.has(edge.destination_node_name):
			destination_graph_node = graph_nodes[edge.destination_node_name]
		else:
			destination_graph_node = SignalGraphNode.instantiate()
			destination_graph_node.title = edge.destination_node_name
			destination_graph_node.name = _get_graph_node_name(edge.destination_node_name)
			graph.add_child(destination_graph_node)
			graph_nodes[edge.destination_node_name] = destination_graph_node
		
		var source_signal = signal_graph.get_source_signal_for_edge(edge)
		var source_graph_node: SignalGraphNode = graph_nodes[edge.source_node_name] as SignalGraphNode
		
		var source_signal_label = Label.new()
		source_signal_label.text = _get_source_graph_node_text(source_signal, edge)
		source_signal_label.name = "source_" + source_signal.signal_name + "_" + edge.destination_node_name
		
		var destination_signal_item = GraphNodeItem.instantiate()
		destination_signal_item.signal_data = SignalGraphNodeItem.Metadata.new(source_signal.signal_name, edge.method_signature, edge.destination_node_name)
		destination_signal_item.text = _get_destination_graph_node_text(source_signal, edge)
		destination_signal_item.name = "destination_" + source_signal.signal_name + "_" + edge.method_signature
		destination_signal_item.open_script.connect(_on_open_signal_in_script)
		
		source_graph_node.add_child(source_signal_label)
		destination_graph_node.add_child(destination_signal_item)
	
	for edge in signal_graph.edges:
		var source_signal = signal_graph.get_source_signal_for_edge(edge)
		var source_graph_node: SignalGraphNode = graph_nodes[edge.source_node_name] as SignalGraphNode
		var destination_graph_node: SignalGraphNode = graph_nodes[edge.destination_node_name] as SignalGraphNode
		
		var next_source_slot = source_graph_node.get_next_source_slot(source_signal.signal_name, edge.destination_node_name)
		var next_destination_slot = destination_graph_node.get_next_destination_slot(source_signal.signal_name, edge.method_signature)
		
		source_graph_node.set_slot(next_source_slot, false, CONNECTION_TYPE, Color.BLACK, true, CONNECTION_TYPE, SOURCE_COLOR)
		destination_graph_node.set_slot(next_destination_slot, true, CONNECTION_TYPE, DESTINATION_COLOR, false, CONNECTION_TYPE, Color.BLACK)
		
		var from_port = source_graph_node.get_source_slot(source_signal.signal_name, edge.destination_node_name)
		var to_port = destination_graph_node.get_destination_slot(source_signal.signal_name, edge.method_signature)
		
		if from_port >= 0 and to_port >= 0:
			graph.connect_node(source_graph_node.name, from_port, destination_graph_node.name, to_port)
		else:
			print(">>> Invalid Connection Request")

func _generate_tree(signal_graph: SignalGraph):
	var root = signal_tree.create_item()
	root.set_text(0, signal_graph.name)
	
	var tree_items: Dictionary = {}
	
	for signal_item in signal_graph.signals:
		var node_tree_item: TreeItem
		if tree_items.has(signal_item.node_name):
			node_tree_item = tree_items[signal_item.node_name] as TreeItem
		else:
			node_tree_item = signal_tree.create_item(root)
			node_tree_item.set_text(0, signal_item.node_name)
			tree_items[signal_item.node_name] = node_tree_item
		
		var signal_tree_item = signal_tree.create_item(node_tree_item)
		signal_tree_item.set_text(0, signal_item.signal_name)
			
		for edge in signal_graph.edges.filter(func (item): return item.signal_id == signal_item.id):
			var signal_connection_tree_item = signal_tree.create_item(signal_tree_item)
			signal_connection_tree_item.set_text(0, edge.destination_node_name + "::" + edge.method_signature)

func _get_graph_node_name(name: String) -> String:
	return "{node_name}_graph_node".format({ "node_name": name })

func _get_source_graph_node_text(source_signal: SignalDescription, edge: SignalConnection) -> String:
	if signal_details_checkbox.button_pressed:
		return source_signal.signal_name + " -> " + edge.destination_node_name
	
	return source_signal.signal_name

func _get_destination_graph_node_text(source_signal: SignalDescription, edge: SignalConnection) -> String:
	if signal_details_checkbox.button_pressed:
		return source_signal.signal_name + "::" + edge.method_signature
	
	return edge.method_signature

func _gather_nodes_in_scene() -> Array[Node]:
	var scene_root = get_tree().edited_scene_root
	var node_list: Array[Node] = [scene_root]
	return node_list + _gather_nodes_from_node(scene_root)

func _gather_nodes_from_node(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(false):
		nodes.append(child)
		nodes += _gather_nodes_from_node(child)
	
	return nodes
