@tool
class_name SignalGraphNode extends GraphNode

# Properties
# |===================================|
# |===================================|
# |===================================|

var connections: Array = [] :
	get: return connections
	set(new_value):
		connections = new_value

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _ready():
	selectable = true
	resizable = true
	draggable = true

# Signals
# |===================================|
# |===================================|
# |===================================|

func _on_resize_request(new_minsize):
	size = new_minsize

# Methods
# |===================================|
# |===================================|
# |===================================|

func has_source_signal_description(signal_name: String, destination_node_name: String) -> bool:
	for child in get_children():
		if child.name == "source_" + signal_name + "_" + destination_node_name:
			return true
	
	return false

func get_source_slot(signal_name: String, destination_node_name: String) -> int:
	var index = 0
	for child in get_children():
		if child.name == "source_" + signal_name + "_" + destination_node_name:
			return index

		index += 1

	return -1

func get_next_source_slot(signal_name: String, destination_node_name: String) -> int:
	var index = 0
	for child in get_children():
		if child.name.begins_with("source_"):
			if child.name == "source_" + signal_name + "_" + destination_node_name:
				return index

			index += 1

	return -1

func has_destination_signal_description(signal_name: String, method_signature: String) -> bool:
	for child in get_children():
		if child.name == "destination_" + signal_name + "_" + _sanitize_method_signature(method_signature):
			return true
	
	return false

func get_destination_slot(signal_name: String, method_signature: String) -> int:
	var index = 0
	for child in get_children():
		if child.name == "destination_" + signal_name + "_" + _sanitize_method_signature(method_signature):
			return index

		index += 1

	return -1

func get_next_destination_slot(signal_name: String, method_signature: String) -> int:
	var index = 0
	for child in get_children():
		if child.name.begins_with("destination_"):
			if child.name == "destination_" + signal_name + "_" + _sanitize_method_signature(method_signature):
				return index

			index += 1

	return -1

func _sanitize_method_signature(signature: String) -> String:
	return signature.replace("::", "__")
