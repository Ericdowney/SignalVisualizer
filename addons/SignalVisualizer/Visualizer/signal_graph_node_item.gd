@tool
class_name SignalGraphNodeItem extends Control

signal open_script(metadata: SignalGraphNodeItem.Metadata)

class Metadata:
	var signal_name: String
	var method_signature: String
	var node_name: String
	
	func _init(signal_name: String, method_signature: String, node_name: String):
		self.signal_name = signal_name
		self.method_signature = method_signature
		self.node_name = node_name

# Properties
# |===================================|
# |===================================|
# |===================================|

@onready var label: Label = %DescriptionLabel

var signal_data: Metadata = null

var text: String = "" :
	get: return text
	set(new_value):
		text = new_value
		if label:
			label.text = text

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _ready():
	_update()

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_open_signal_in_script_button_pressed():
	open_script.emit(signal_data)

# Methods
# |===================================|
# |===================================|
# |===================================|

func _update():
	label.text = text
	
	var text_size = label.get_text_size()
	custom_minimum_size = Vector2((text_size.x * 2) + 50, text_size.y * 3)
