extends Node3D

signal place
var place_positon = Vector3(0, 0, 0)
var rotation_state = 0
var rotation_delta = 45
var preview: Node3D
var selected
func _ready():
	preview = load("res://assets/trainStation.tscn").instantiate()
	place.connect(preview._place)
	add_child(preview)
	
func _process(delta):
	var result = raycast()
	
	self.rotation_degrees = Vector3(0, rotation_state, 0)
	if result:
		result.position.y += 1
		position = result.position

func _input(event):
	if event.is_action("scroll_up") || event.is_action("scroll_down"):
		var scroll_input = Input.get_axis("scroll_up", "scroll_down")
		rotation_state += rotation_delta * scroll_input
		rotation_state = wrapf(rotation_state, 0, 360)
	if event.is_action_pressed("left_click"):
		var result = raycast()
		if result:
			result.position.y += 1
			place_positon = result.position
			_place()

func _on_inventory_item_selected(item):
	var transform = self.transform
	place.disconnect(preview._place)
	remove_child(preview)
	preview = load(item).instantiate()
	self.transform = transform
	for child in preview.get_children():
		if child is Sprite3D:
			preview.remove_child(child)
	place.connect(preview._place)
	add_child(preview)

func _place(node: Path3D = null, point = -1):
	if point != -1 and node != null:
		preview._place(position, Vector3(0, rotation_state, 0), node, point)
	else:
		preview._place(position, Vector3(0, rotation_state, 0))

func raycast():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = %Character/Camera3D.project_ray_origin(mouse_position)
	params.to = params.from + %Character/Camera3D.project_ray_normal(mouse_position) * 1000
	return space_state.intersect_ray(params)
