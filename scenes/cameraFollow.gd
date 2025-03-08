extends Camera3D

func _process(delta: float) -> void:
	var train = get_tree().get_first_node_in_group("trains")
	if train != null:
		position = train.position + Vector3(20, 20, 20)
		look_at(train.position)
