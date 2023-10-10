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

func get_next_source_slot(signal_name: String, destination_node_name: String) -> int:
	var index = 0
	for child in get_children():
		if child.name == "source_" + signal_name + "_" + destination_node_name:
			return index

		index += 1

	return 0

func get_source_slot(signal_name: String, destination_node_name: String) -> int:
	var index = 0
	for child in get_children():
		if child.name.begins_with("source_"):
			if child.name == "source_" + signal_name + "_" + destination_node_name:
				return index

			index += 1

	return 0

func get_next_destination_slot(signal_name: String, method_signature: String) -> int:
	var index = 0
	for child in get_children():
		if child.name == "destination_" + signal_name + "_" + method_signature:
			return index

		index += 1

	return 0

func get_destination_slot(signal_name: String, method_signature: String) -> int:
	var index = 0
	for child in get_children():
		if child.name.begins_with("destination_"):
			if child.name == "destination_" + signal_name + "_" + method_signature:
				return index

			index += 1

	return 0
