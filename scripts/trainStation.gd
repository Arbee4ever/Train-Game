extends Node3D

func _place(location: Vector3, rotation_degrees: Vector3):
	var building = self.duplicate()
	building.position = location
	building.rotation_degrees = rotation_degrees
	for child in building.get_children():
		if child is Path3D:
			child._add_markers()
	get_tree().get_root().get_node("World").add_child(building)

func _on_toggle_select():
	pass
