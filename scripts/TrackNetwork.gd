extends Resource
class_name TrackNetwork

@export var points = []
@export var tracks = []

func add_point(position: Vector3) -> Point:
	var point = Point.new()
	point.position = position
	points.append(point)
	return point

func add_track(start_point: Point, end_point: Point, type, properties = {}) -> void:
	var track = Track.new()
	start_point.connections.append(track)
	end_point.connections.append(track)
	track.start = start_point
	track.end = end_point
	track.type = type
	track.properties = properties
	tracks.append(track)
