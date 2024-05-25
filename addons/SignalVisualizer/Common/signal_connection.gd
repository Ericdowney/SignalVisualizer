class_name SignalConnection extends Object

# Properties
# |===================================|
# |===================================|
# |===================================|

var signal_id: int
var source_node_name: String
var destination_node_name: String
var method_signature: String

var description: String :
	get:
		return "ID: {signal_id} Source: {source_node_name} Destination: {destination_node_name} Method: {method_signature}".format({
			"signal_id": signal_id,
			"source_node_name": source_node_name,
			"destination_node_name": destination_node_name,
			"method_signature": method_signature,
		})

var dictionary_key: String :
	get:
		return "{signal_id}__{source_node_name}__{destination_node_name}__{method_signature}".format({ "signal_id": signal_id, "source_node_name": source_node_name, "destination_node_name": destination_node_name, "method_signature": method_signature.replace("::", "_") })

var dictionary_representation: Dictionary :
	get:
		return {
			"signal_id": signal_id,
			"source_node_name": source_node_name,
			"destination_node_name": destination_node_name,
			"method_signature": method_signature,
		}

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _init(signal_id: int, source_node_name: String, destination_node_name: String, method_signature: String):
	self.signal_id = signal_id
	self.source_node_name = source_node_name
	self.destination_node_name = destination_node_name
	self.method_signature = method_signature

# Signals
# |===================================|
# |===================================|
# |===================================|



# Methods
# |===================================|
# |===================================|
# |===================================|


