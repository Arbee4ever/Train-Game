extends Resource
class_name TrackNetwork

signal point_added(point)
signal point_changed(point)
signal track_added(track)

@export var points = []
@export var tracks = []

func add_point(point: Point, connected_to: Point = null) -> Point:
	point.commit()
	var point_count = len(points)
	if connected_to != null:
		point.connections.append(add_track(connected_to, point))
	point.id = point_count
	point.on_move.connect(on_move_point)
	point.on_in_change.connect(on_set_point_in)
	point.on_out_change.connect(on_set_point_out)
	points.append(point)
	point_added.emit(point)
	return point
	
func on_move_point(point: Point) -> void:
	point_changed.emit(point)
	
func on_set_point_in(point: Point) -> void:
	point_changed.emit(point)
	
func on_set_point_out(point: Point) -> void:
	point_changed.emit(point)

func add_track(start_point: Point, end_point: Point) -> Track:
	var track = Track.new()
	start_point.connections.append(track)
	end_point.connections.append(track)
	track.start = start_point
	track.end = end_point
	tracks.append(track)
	track_added.emit(track)
	return track
