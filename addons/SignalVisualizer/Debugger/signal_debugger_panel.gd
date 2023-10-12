@tool
class_name SignalDebuggerPanel extends Control

signal start_signal_debugging
signal stop_signal_debugging

# Properties
# |===================================|
# |===================================|
# |===================================|

@export var start_icon: Texture2D
@export var stop_icon: Texture2D

@onready var action_button: Button = %ActionButton
@onready var clear_button: Button = %ClearButton
@onready var signal_tree: Tree = %SignalTree
@onready var log_label: RichTextLabel = %LogLabel

var is_started: bool = false :
	get: return is_started
	set(new_value):
		is_started = new_value
		_update_action_button()

var _signals: Array = []

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _ready():
	disable()

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_action_button_pressed():
	if is_started:
		stop()
	else:
		start()

func _on_clear_button_pressed():
	log_label.clear()
	signal_tree.clear()

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
			tree_items[signal_item.node_name] = node_tree_item
		
		var signal_tree_item = signal_tree.create_item(node_tree_item)
		signal_tree_item.set_text(0, signal_item.signal_name)

func log_signal_execution(time: String, node_name: String, signal_name: String):
	if not log_label.text.is_empty():
		log_label.newline()
	log_label.append_text(
		"[color=#FFCC00]{time}[/color]\t\t{node_name}\t\t{signal_name}".format({ "time": time, "node_name": node_name, "signal_name": signal_name })
	)
	log_label.newline()

func _update_action_button():
	if is_started:
		action_button.text = "Stop"
		action_button.modulate = Color("#ff3b30")
	else:
		action_button.text = "Start"
		action_button.modulate = Color.WHITE
