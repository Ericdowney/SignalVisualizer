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

# Lifecycle
# |===================================|
# |===================================|
# |===================================|



# Signals
# |===================================|
# |===================================|
# |===================================|



# Methods
# |===================================|
# |===================================|
# |===================================|


