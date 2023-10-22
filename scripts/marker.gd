extends Node3D

func toggle_visibility(visible):
	self.visible = visible

signal place()
var path: Path3D
var point = -1

func _ready():
	path = get_parent()
	place.connect(get_node("/root/World/Builder")._place)

func _on_collider_input_event(camera, event: InputEvent, position, normal, shape_idx):
	if event.is_action_pressed("left_click"):
		point = path.curve.get_baked_points().find(path.curve.get_closest_point(path.to_local(position)))

func _input(event):
	if event.is_action_released("left_click"):
		if point != -1 and path != null:
			place.emit(path, point)
			point = -1
