class_name SignalDescription extends Object

# Properties
# |===================================|
# |===================================|
# |===================================|

var id: int:
	get: return get_instance_id()
	
var node_name: String
var signal_name: String

var description: String :
	get:
		return "ID: {id} Node: {node_name} Signal: {signal_name}".format({
			"id": id,
			"node_name": node_name,
			"signal_name": signal_name,
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


