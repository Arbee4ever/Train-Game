class_name Point
var position: Vector3 = Vector3.ZERO
var vector_in: Vector3 = Vector3.ZERO
var vector_out: Vector3 = Vector3.ZERO
var connected_to: Array[int] = []

func _init(position: Vector3, vector_in = Vector3.ZERO, vector_out = Vector3.ZERO, connected_to = []):
	self.vector_in = vector_in
	self.vector_out = vector_out
	self.position = position
	self.connected_to.assign(connected_to)

func set_vector_in(vector: Vector3):
	vector_in = vector
	
func set_vector_out(vector: Vector3):
	vector_out = vector
