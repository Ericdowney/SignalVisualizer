@tool
class_name SignalDebuggerPanel extends Control

signal open_script(node_name: String, method_signature: String)

signal start_signal_debugging
signal stop_signal_debugging

var SignalGraphNode = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node.tscn")
var GraphNodeItem = preload("res://addons/SignalVisualizer/Visualizer/signal_graph_node_item.tscn")

const SOURCE_COLOR: Color = Color.SKY_BLUE
const DESTINATION_COLOR: Color = Color.CORAL
const CONNECTION_TYPE: int = 0

enum Tabs {
	LOG,
	GRAPH
}

# Properties
# |===================================|
# |===================================|
# |===================================|

@export var start_icon: Texture2D
@export var stop_icon: Texture2D

@onready var action_button: Button = %ActionButton
@onready var clear_all_button: Button = %ClearAllButton
@onready var signal_tree: Tree = %SignalTree
@onready var log_label: RichTextLabel = %LogLabel
@onready var graph_node: GraphEdit = %Graph

var is_started: bool = false :
	get: return is_started
	set(new_value):
		is_started = new_value
		_update_action_button()

var _signals: Array = []
var _signal_filter: Array = []
var _is_stack_trace_enabled: bool = false
var _debugger_tab_state: Tabs = Tabs.LOG
var _graph: SignalGraph

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _ready():
	disable()
	_handle_tab_update(0)

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_action_button_pressed():
	if is_started:
		stop()
	else:
		start()

func _on_clear_all_button_pressed():
	log_label.clear()
	signal_tree.clear()
	graph_node.clear_connections()
	for child in graph_node.get_children():
		if child is SignalGraphNode:
			child.queue_free()

func _on_clear_logs_button_pressed():
	log_label.clear()

func _on_signal_tree_item_selected():
	# Updates the checkmark button
	var selected_item = signal_tree.get_selected()
	var is_checked = selected_item.is_checked(1)
	selected_item.set_checked(1, (not is_checked))
	
	# Add / Remove signal from filters
	var selected_signal = _signals.filter(func (element): return element.signal_name == selected_item.get_text(0))[0]
	if _signal_filter.has(selected_signal.signal_name):
		var selected_index = _signal_filter.find(selected_signal.signal_name)
		_signal_filter.remove_at(selected_index)
	else:
		_signal_filter.append(selected_signal.signal_name)

func _on_tab_bar_tab_changed(tab: int):
	_handle_tab_update(tab)

func _on_stack_trace_button_pressed():
	_is_stack_trace_enabled = not _is_stack_trace_enabled

func _on_open_signal_in_script(data: SignalGraphNodeItem.Metadata):
	open_script.emit(data.node_name, data.method_signature)

# Methods
# |===================================|
# |===================================|
# |===================================|

func enable():
	action_button.disabled = false

func disable():
	action_button.disabled = true

func start():
	if not is_started:
		is_started = true
		action_button.icon = stop_icon
		start_signal_debugging.emit()
		log_label.append_text("[color=#B0B0B0]Signal Debugging Started...[/color]")
		log_label.newline()
		log_label.newline()

func stop():
	if is_started:
		is_started = false
		action_button.icon = start_icon
		stop_signal_debugging.emit()
		log_label.newline()
		log_label.append_text("[color=#B0B0B0]Signal Debugging Stopped[/color]")
		log_label.newline()
		log_label.newline()

func create_tree_from_signals(signals: Array):
	_signals = signals
	var root = signal_tree.create_item()
	root.set_text(0, "Signals")
	
	var tree_items: Dictionary = {}
	
	for signal_item in signals:
		var node_tree_item: TreeItem
		if tree_items.has(signal_item.node_name):
			node_tree_item = tree_items[signal_item.node_name] as TreeItem
		else:
			node_tree_item = signal_tree.create_item(root)
			node_tree_item.set_text(0, signal_item.node_name)
			node_tree_item.set_selectable(0, false)
			node_tree_item.set_selectable(1, false)
			tree_items[signal_item.node_name] = node_tree_item
		
		var signal_tree_item = signal_tree.create_item(node_tree_item)
		signal_tree_item.set_text(0, signal_item.signal_name)
		signal_tree_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		signal_tree_item.set_checked(1, true)
		signal_tree_item.set_selectable(0, false)
		signal_tree_item.set_selectable(1, true)

func create_signal_graph(signals: Array, edges: Array):
	_graph = SignalGraphUtility.create_signal_graph(get_tree().edited_scene_root.scene_file_path, signals, edges)
	SignalGraphUtility.generate_signal_graph_nodes(_graph, graph_node, _on_open_signal_in_script)

func log_signal_execution(time: String, node_name: String, signal_name: String):
	if _signal_filter != null and _signal_filter.has(signal_name):
		return
	
	if not log_label.text.is_empty():
		log_label.newline()
	log_label.append_text(
		"[color=#FFCC00]{time}[/color]\t\t{node_name}\t\t{signal_name}".format({ "time": time, "node_name": node_name, "signal_name": signal_name })
	)
	log_label.newline()

func _handle_tab_update(selected_tab_index: int):
	match selected_tab_index:
		1:
			_debugger_tab_state = Tabs.GRAPH
		_:
			_debugger_tab_state = Tabs.LOG
	
	match _debugger_tab_state:
		Tabs.LOG:
			log_label.show()
			graph_node.hide()
		Tabs.GRAPH:
			log_label.hide()
			graph_node.show()

func _update_action_button():
	if is_started:
		action_button.text = "Stop"
		action_button.modulate = Color("#ff3b30")
	else:
		action_button.text = "Start"
		action_button.modulate = Color.WHITE
