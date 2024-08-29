extends Node3D

signal action_pressed(position)

var network := TrackNetwork.new()
@onready var path: Path3D = _get_path()

func _ready() -> void:
	network.point_added.connect(point_added)
	network.point_changed.connect(point_changed)
	network.track_added.connect(track_added)

enum building_state {POINT, CONTROL}
var state = building_state.POINT
var point = null
var line1 = null
var line2 = null
var line3 = null
func _on_ground_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if line1 != null and point != null:
		if line3 != null:
			line3.queue_free()
			line3 = null
		line3 = await Draw3D.line(point.position + point.vector_out, event_position, Color.RED)
	if line1 == null and point != null:
		if line2 != null:
			line2.queue_free()
			line2 = null
		line2 = await Draw3D.line(point.position, event_position, Color.BLACK)
	if event.is_action_pressed("action") and state == building_state.POINT:
		point = network.add_point(event_position)
		if line1 != null:
			line1.queue_free()
			line1 = null
		state = building_state.CONTROL
	elif event.is_action_pressed("action") and state == building_state.CONTROL:
		network.set_point_out(point, event_position - point.position)
		line1 = await Draw3D.line(point.position, point.position + point.vector_out, Color.BLACK)
		state = building_state.POINT
		
func point_added(point):
	var marker = preload("res://scenes/Point.tscn").instantiate()
	marker.position = point.position
	add_child(marker)
	var point_count = len(network.points)
	if point_count > 1:
		network.add_track(network.points[point_count - 2], network.points[point_count - 1])
		
func point_changed(point):
	var id = network.get_point_id(point)
	path.curve.set_point_in(id, point.vector_in)
	path.curve.set_point_out(id, point.vector_out)
	path.curve.set_point_position(id, point.position)

func track_added(track):
	var point_count = len(network.points)
	if point_count == 2:
		var newPoint = network.points[point_count - 2]
		path.curve.add_point(newPoint.position, newPoint.vector_in, newPoint.vector_out)
	var newPoint = network.points[point_count - 1]
	path.curve.add_point(newPoint.position, newPoint.vector_in, newPoint.vector_out)
	
func rebuild_path():
	path.curve.clear_points()
	for point in get_tree().get_nodes_in_group("points"):
		point.queue_free()
	for point: Point in network.points:
		path.curve.add_point(point.position, point.vector_in, point.vector_out)
		var marker = preload("res://scenes/Point.tscn").instantiate()
		marker.position = point.position
		add_child(marker)

func _get_path() -> Path3D:
	if path == null:
		path = preload("res://scenes/Track.tscn").instantiate()
		path.curve.clear_points()
		add_child(path)
	return path

func add_train():
	path.add_child(preload("res://scenes/Train.tscn").instantiate())
	
var debug_lines = []
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		%Character.reparent(self)
		%Character.locked = false
	elif event.is_action_pressed("debug"):
		if len(debug_lines) == 0:
			for point in network.points:
				debug_lines.append(await Draw3D.line(point.position, point.position + point.vector_out, Color.BLACK))
		else:
			for line in debug_lines:
				line.queue_free()
			debug_lines.clear()
