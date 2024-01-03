class_name Track extends Node3D

var points: Array[Point] = []
var markers = []
@export
var path: Path3D
var selectedPoint = -1

func get_point_count():
	return points.size()
	
func add_point(position: Vector3, index: int = -1):
	if  index <= get_point_count():
		selectedPoint = index
		var newPoint = Point.new(to_local(position))
		if index == 0:
			points.push_front(newPoint)
		else:
			points.push_back(newPoint)
		print(points.map(func(number): return number.position))
		
func set_point(position: Vector3, index):
	selectedPoint = index
	points[index].position = position
	var currentPoint: Point = get_point(index + 1)
	var previousPoint: Point = get_point(index)
	previousPoint.vector_out = previousPoint.vector_out.normalized() * previousPoint.position.distance_to(currentPoint.position)/2
	currentPoint.vector_in = ((previousPoint.position + previousPoint.vector_out) - currentPoint.position)/2
	currentPoint.vector_out = -currentPoint.vector_in
	print("previousPoint pos ", previousPoint.position)
	print("previousPoint vecIn ", previousPoint.vector_in)
	print("previousPoint vecOut ", previousPoint.vector_out)
	print("currentPoint pos ", currentPoint.position)
	print("currentPoint vecIn ", currentPoint.vector_in)
	print("currentPoint vecOut ", currentPoint.vector_out)
	
func remove_point(index):
	points.remove_at(index)
	build_path()
	
func get_point(index: int) -> Point:
	if index < 0:
		return null
	return points[index]

func build_path():
	path.curve.clear_points()
	for i in range(get_point_count()):
		path.curve.add_point(points[i].position)
		path.curve.set_point_in(i, points[i].vector_in)
		path.curve.set_point_out(i, points[i].vector_out)
	markers.append(add_marker(get_point(0).position, 0))
	markers.append(add_marker(get_point(get_point_count()-1).position, get_point_count()-1))

func update_path():
	if get_point_count() > path.curve.point_count:
		path.curve.clear_points()
		print("E",path.curve.get_baked_points())
		for i in range(get_point_count()):
			print("I ", i)
			print(points.map(func(number): return number.position))
			path.curve.add_point(points[i].position, points[i].vector_in, points[i].vector_out)
	for i in range(get_point_count()):
		path.curve.set_point_position(i, points[i].position)
		path.curve.set_point_in(i, points[i].vector_in)
		path.curve.set_point_out(i, points[i].vector_out)
	markers[0].position = get_point(0).position
	markers[0].point = 0
	markers[1].position = get_point(get_point_count()-1).position
	markers[1].point = get_point_count()-1

func add_marker(newPosition: Vector3, point):
	var marker = load("res://assets/marker.tscn").instantiate()
	marker.position = newPosition
	marker.point = point
	add_child(marker)
	return marker
