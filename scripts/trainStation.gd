extends Node3D

func _place(location: Vector3, rotation_degrees: Vector3):
	var building = self.duplicate()
	building.position = location
	building.rotation_degrees = rotation_degrees
	get_tree().get_root().get_node("World").add_child(building)
