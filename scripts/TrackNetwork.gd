extends Resource
class_name TrackNetwork

signal point_added(point)
signal point_changed(point)
signal track_added(track)

@export var points = []
@export var tracks = []

func add_point(position: Vector3) -> Point:
	var point_count = len(points)
	var point = Point.new()
	point.position = position
	if point_count >= 1:
		var prevPoint = points[point_count - 1]
		if prevPoint.vector_out == Vector3.ZERO:
			point.vector_in = (prevPoint.position - point.position).normalized() * 50
		else:
			point.vector_in = -(point.position - (prevPoint.position + prevPoint.vector_out))
		point.vector_out = -point.vector_in
	points.append(point)
	point_added.emit(point)
	return point
	
func set_point_out(point: Point, vector_out: Vector3) -> void:
	point.vector_out = vector_out
	point_changed.emit(point)
	
func set_point_in(point: Point, vector_in: Vector3) -> void:
	point.vector_in = vector_in
	point_changed.emit(point)

func move_point(point: Point, position: Vector3) -> void:
	point.position = position
	point_changed.emit(point)
	
func get_point_id(point: Point) -> int:
	return points.find(point)

func add_track(start_point: Point, end_point: Point) -> void:
	var track = Track.new()
	start_point.connections.append(track)
	track.connection = end_point
	tracks.append(track)
	track_added.emit(track)
