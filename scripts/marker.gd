extends Node3D

func toggle_visibility(visible):
	self.visible = visible

signal place()
signal select(position)
var path: Path3D
var point = -1

func _ready():
	place.connect(get_node("/root/World/Builder")._place)

func _on_collider_input_event(camera, event: InputEvent, position, normal, shape_idx):
	path = get_parent()
	select.connect(path._start_drag)
	point = path.curve.get_baked_points().find(path.curve.get_closest_point(position))
	if event.is_action_pressed("left_click"):
		place.emit()

func _input(event):
	if event.is_action_released("left_click"):
		if point != -1 and path is Path3D:
			select.emit(path.curve.get_point_position(point))
			place.emit(path, point)
			point = null
			path = null
