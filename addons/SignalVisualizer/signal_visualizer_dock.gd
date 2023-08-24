@tool
extends Control

var SignalGraphNode = preload("res://addons/SignalVisualizer/signal_graph_node.tscn")

# Properties
# |===================================|
# |===================================|
# |===================================|

const SOURCE_COLOR: Color = Color.SKY_BLUE
const DESTINATION_COLOR: Color = Color.CORAL
const CONNECTION_TYPE: int = 0

@export var button_texture: Texture2D

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

func _on_clear_nodes_button_pressed():
	clear()

func _on_gather_nodes_button_pressed():
	clear()
	
	var scene_signal_graph = SignalVisualizerManager.generate_signal_graph()
	_generate_signal_graph(scene_signal_graph)
	_generate_tree(scene_signal_graph)
	graph.arrange_nodes()

func _on_signal_tree_button_clicked(item, column, id, mouse_button_index):
	print(">>> Tree Button Clicked: ", item)

# Methods
# |===================================|
# |===================================|
# |===================================|

func clear():
	_clear_graph_nodes()
	_clear_tree()

func _clear_graph_nodes():
	graph.clear_connections()
	for child in graph.get_children():
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
		source_signal_label.text = source_signal.signal_name + " -> " + edge.destination_node_name
		source_signal_label.name = "source_" + source_signal.signal_name + "_" + edge.destination_node_name
		
		var destination_signal_label = Label.new()
		destination_signal_label.text = source_signal.signal_name + "::" + edge.method_signature
		destination_signal_label.name = "destination_" + source_signal.signal_name + "_" + edge.method_signature
		
		source_graph_node.add_child(source_signal_label)
		destination_graph_node.add_child(destination_signal_label)
	
	for edge in signal_graph.edges:
		var source_signal = signal_graph.get_source_signal_for_edge(edge)
		var source_graph_node: SignalGraphNode = graph_nodes[edge.source_node_name] as SignalGraphNode
		var destination_graph_node: SignalGraphNode = graph_nodes[edge.destination_node_name] as SignalGraphNode
		
		var next_source_slot = source_graph_node.get_next_source_slot(source_signal.signal_name, edge.destination_node_name)
		var next_destination_slot = destination_graph_node.get_next_destination_slot(source_signal.signal_name, edge.method_signature)
		
		source_graph_node.set_slot(next_source_slot, false, CONNECTION_TYPE, Color.BLACK, true, CONNECTION_TYPE, SOURCE_COLOR)
		destination_graph_node.set_slot(next_destination_slot, true, CONNECTION_TYPE, DESTINATION_COLOR, false, CONNECTION_TYPE, Color.BLACK)
		
		var from_port = source_graph_node.get_source_slot(source_signal.signal_name, edge.destination_node_name)#source_graph_node.get_connection_output_slot(next_source_slot)
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
