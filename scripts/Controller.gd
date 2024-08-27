extends Node3D

var network

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton and event.is_pressed()):
		network = TrackNetwork.new()
		var point1 = network.add_point(Vector3.ZERO)
		var point2 = network.add_point(Vector3(100, 100, 100))
		network.add_track(point1, point2, "test")
		print(network.tracks[0].start.position)
		var path = "res://network.tres"
		var result = ResourceSaver.save(network, path)
		assert(result == OK)
		network = ResourceLoader.load(path)
		print(network.points[1].position)
