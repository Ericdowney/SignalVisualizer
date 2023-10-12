class_name SignalGraph extends Object

# Properties
# |===================================|
# |===================================|
# |===================================|

var name: String
var signals: Array[SignalDescription]
var edges: Array[SignalConnection]

var description: String :
	get:
		return "Signals: {signals}\nEdges: {edges}".format({
			"signals": signals.map(func (item): return item.description),
			"edges": edges.map(func (item): return item.description),
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

func get_source_signal_for_edge(edge: SignalConnection) -> SignalDescription:
	var result = signals.filter(func (item): return item.id == edge.signal_id)
	if result.size() > 0:
		return result[0]
	return null
