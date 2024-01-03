extends Node3D

var path_data = {}

var type = "track"
var building = load("res://assets/%s.tscn" % type).instantiate()
var placing = false

var rotation_state = 0
var rotation_delta = 360/16

var start_pos = Vector3.ZERO
var end_pos = Vector3.ZERO
var curve = false

func build(camera, event: InputEvent, position, normal, shape_idx):
	if event.is_action_pressed("left_click"):
		placing = true
		building.position = position
		start_pos = position
		end_pos = start_pos + Vector3.FORWARD
		get_parent().add_child(building)
		match type:
			"track":
				building.add_point(start_pos)
				building.add_point(end_pos, 0)
				building.build_path()
			"trainStation":
				var track: Track = building.find_child("Track")
				track.add_point(building.position + Vector3(0, 0, 10))
				track.add_point(building.position + Vector3(0, 0, -10), 0)
				track.build_path()
		updatePos()
		updateRot()

var curvature_rate = 100
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_released("left_click"):
		if placing:
			match type:
				"track":
					if building.get_point(building.get_point_count()-1).position.distance_to(building.get_point(building.get_point_count()-2).position) < 10 \
					or (building.get_point_count() > 2 and building.get_point(building.get_point_count()-1).vector_in.angle_to(building.get_point(building.get_point_count()-2).vector_out) < 0.8):
						building.remove_point(building.get_point_count()-1)
						
			building = load("res://assets/%s.tscn" % type).instantiate()
			placing = false
	
	if event is InputEventMouseMotion:
		if placing == false:
			return
		var result = raycast()
		if result:
			end_pos = result.position
			updatePos()
			updateRot()

	if event.is_action("scroll_up") || event.is_action("scroll_down"):
		var scroll_input = Input.get_axis("scroll_up", "scroll_down")
		if Input.is_key_pressed(KEY_CTRL):
			curvature_rate -= scroll_input*10
		else:
			rotation_state += rotation_delta * scroll_input
			rotation_state = wrapf(rotation_state, 0, 360)
		updateRot()

func updatePos():
	match type:
		"track":
			building.set_point(building.to_local(end_pos), building.selectedPoint)
			building.update_path()
		"trainStation":
			building.position = end_pos

func updateRot():
	match type:
		"track":
			if curve == true:
				var offset_point = -building.get_point(building.selectedPoint - 1).vector_in
				print(offset_point)
				building.set_point_out(offset_point, building.selectedPoint - 1)
				building.update_path()
		"trainStation":
			building.rotation.y = deg_to_rad(rotation_state)

func raycast():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = %Character/Camera3D.project_ray_origin(mouse_position)
	params.to = params.from + %Character/Camera3D.project_ray_normal(mouse_position) * 1000
	var result = space_state.intersect_ray(params)
	return result
	
func _on_inventory_item_selected(type):
	self.type = type
	building = load("res://assets/%s.tscn" % type).instantiate()

func attachTrack(track, point):
	placing = true
	building = track
	start_pos = raycast().position
	track.add_point(raycast().position, point)
	updateRot()
