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
	
	var scene_signal_graph = SignalGraphUtility.create_signal_graph_from_node(get_tree().edited_scene_root, true)
	SignalGraphUtility.generate_signal_graph_nodes(scene_signal_graph, graph, _on_open_signal_in_script)
	SignalGraphUtility.generate_signal_graph_tree(scene_signal_graph, signal_tree)
	
	if arrange_nodes_checkbox.button_pressed:
		graph.arrange_nodes()

func _on_open_signal_in_script(data: SignalGraphNodeItem.Metadata):
	open_script.emit(data.node_name, data.method_signature)

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
		if child is SignalGraphNode:
			child.queue_free()

func _clear_tree():
	signal_tree.clear()
