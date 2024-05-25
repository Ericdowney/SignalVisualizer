class_name SignalDescription extends Object

# Properties
# |===================================|
# |===================================|
# |===================================|

var id: int:
	get:
		if _source_id != null:
			return _source_id
		return get_instance_id()
	
var node_name: String
var signal_name: String

var description: String :
	get:
		return "ID: {id} Node: {node_name} Signal: {signal_name}".format({
			"id": id,
			"node_name": node_name,
			"signal_name": signal_name,
		})

var dictionary_representation: Dictionary :
	get:
		return {
			"id": id,
			"node_name": node_name,
			"signal_name": signal_name,
		}

var _source_id = null

# Lifecycle
# |===================================|
# |===================================|
# |===================================|

func _init(node_name: String, signal_name: String):
	self.node_name = node_name
	self.signal_name = signal_name

# Signals
# |===================================|
# |===================================|
# |===================================|



# Methods
# |===================================|
# |===================================|
# |===================================|


