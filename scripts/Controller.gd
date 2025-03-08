extends Node3D

var network := TrackNetwork.new()
@onready var path: Path3D = _get_path()
@onready var selectionTrack: Path3D = $SelectionTrack

func _ready() -> void:
	network.point_added.connect(point_added)
	network.point_changed.connect(point_changed)
	#network.track_added.connect(track_added)

enum building_state {POINT, CONTROL}
var state = building_state.POINT
var prevPoint = null
var selectedPoint: Point = null:
	set(newPoint):
		if selectedPoint != null:
			selectedPoint.on_move.disconnect(selectionTrack.update)
			selectedPoint.on_in_change.disconnect(selectionTrack.update)
			selectedPoint.on_out_change.disconnect(selectionTrack.update)
		selectedPoint = newPoint
		selectedPoint.on_move.connect(selectionTrack.update)
		selectedPoint.on_in_change.connect(selectionTrack.update)
		selectedPoint.on_out_change.connect(selectionTrack.update)
var pointLine = null
var controlLine = null
func _on_ground_input_event(camera: Node, event: InputEvent, eventPosition: Vector3, normal: Vector3, shapeIdx: int) -> void:
	if selectedPoint == null: 
		selectedPoint = Point.new(eventPosition)
	selectedPoint = calculate_vectors(selectedPoint, prevPoint, eventPosition)
	if event is InputEventMouseMotion:
		mouse_move(eventPosition)
	elif event.is_action_pressed("action"):
		build(eventPosition)
		
func mouse_move(eventPosition: Vector3):
	match state:
		building_state.POINT:
			if pointLine != null:
				pointLine.queue_free()
				pointLine = null
			selectedPoint.position = eventPosition
			if prevPoint != null:
				pointLine = await Draw3D.line(prevPoint.position + prevPoint.vector_out, eventPosition, Color.RED)
		building_state.CONTROL:
			if controlLine != null:
				controlLine.queue_free()
				controlLine = null
			if prevPoint != null:
				var newVector: Vector3 = eventPosition - selectedPoint.position
				newVector = newVector.project(-selectedPoint.vector_in.normalized())
				if round(newVector.normalized().dot(selectedPoint.vector_in.normalized())) == -1:
					controlLine = await Draw3D.line(selectedPoint.position, selectedPoint.position + newVector, Color.BLACK)
			else:
				controlLine = await Draw3D.line(selectedPoint.position, eventPosition, Color.BLACK)
				
func build(eventPosition: Vector3):
	if controlLine != null:
		controlLine.queue_free()
		controlLine = null
	match state:
		building_state.POINT:
			add_marker(selectedPoint)
			selectedPoint = network.add_point(selectedPoint, prevPoint)
			state = building_state.CONTROL
		building_state.CONTROL:
			if len(network.points) > 1:
				var track = selectionTrack.render()
				path.add_child(track)
			controlLine = await Draw3D.line(selectedPoint.position, selectedPoint.position + selectedPoint.vector_out, Color.BLACK)
			prevPoint = selectedPoint
			selectedPoint = network.add_point(Point.new(eventPosition), prevPoint)
			state = building_state.POINT
			
func calculate_vectors(point: Point, prevPoint: Point, eventPosition: Vector3):
	match state:
		building_state.POINT:
			if prevPoint != null:
				selectedPoint.vector_in = (prevPoint.position + prevPoint.vector_out) - eventPosition
		building_state.CONTROL:
			if prevPoint != null:
				var newVector: Vector3 = eventPosition - selectedPoint.position
				newVector = newVector.project(-selectedPoint.vector_in.normalized())
				selectedPoint.vector_out = newVector
			else:
				selectedPoint.vector_out = eventPosition - selectedPoint.position
	return point
		
func point_added(point: Point):
	var id = point.id
	path.curve.add_point(point.position)
	path.curve.set_point_in(id, point.vector_in)
	path.curve.set_point_out(id, point.vector_out)
		
func point_changed(point: Point):
	var id = point.id
	path.curve.set_point_in(id, point.vector_in)
	path.curve.set_point_out(id, point.vector_out)
	path.curve.set_point_position(id, point.position)

func rebuild_path():
	path.curve.clear_points()
	get_tree().call_group("markers", "remove")
	for point: Point in network.points:
		path.curve.add_point(point.position, point.vector_in, point.vector_out)
		add_marker(point)

func _get_path() -> Path3D:
	if path == null:
		path = load("res://scenes/Track.tscn").instantiate()
		add_child(path)
	return path

func add_train():
	var train = preload("res://scenes/Train.tscn").instantiate()
	path.add_child(train)
	
func add_marker(point: Point):
	var marker = preload("res://scenes/Marker.tscn").instantiate()
	marker.point = point
	marker.input_event.connect(marker_clicked)
	%Markers.add_child(marker)
	return marker
	
func marker_clicked(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, point: Point):
	if event.is_action_pressed("action"):
		selectedPoint = point
	pass
	
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
