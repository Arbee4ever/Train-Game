@tool
extends Path3D

@export var distance_between_planks = 1.0:
	set(value):
		distance_between_planks = value
		is_dirty = true
	
var is_dirty = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dirty:
		_update_multimesh()

		is_dirty = false
	
func _ready():
	curve = Curve3D.new()
	curve.add_point(Vector3(0, 0, 10))
	curve.add_point(Vector3(0, 0, -10))

func _update_multimesh():
	var path_length: float = curve.get_baked_length()
	var count = floor(path_length / distance_between_planks)

	var mm: MultiMesh = $MultiMeshInstance3D.multimesh
	mm.instance_count = count
	var offset = distance_between_planks/2.0

	for i in range(0, count):
		var curve_distance = offset + distance_between_planks * i
		var position = curve.sample_baked(curve_distance, true)

		var basis = Basis()
		
		var up = curve.sample_baked_up_vector(curve_distance, true)
		var forward = position.direction_to(curve.sample_baked(curve_distance + 0.1, true))

		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward
		
		var transform = Transform3D(basis, position)
		mm.set_instance_transform(i, transform)

func _on_curve_changed():
	is_dirty = true

func _place(location: Vector3, rotation_degrees: Vector3, path = null, point = -1):
	if path != null and point != -1:
		path.curve.add_point(path.to_local(location), Vector3.ZERO, Vector3.ZERO, point)
		var marker = path.add_marker(path.to_local(location))
		marker.visible = true
	else:
		var building = self.duplicate()
		building.position = location
		building.rotation_degrees = rotation_degrees
		building._add_markers()

func _add_markers():
	for i in range(0, curve.point_count):
		add_marker(position + curve.get_point_position(i))
		
func add_marker(position):
	var sprite = load("res://assets/marker.tscn").instantiate()
	sprite.visible = false
	sprite.position = position
	add_child(sprite)
	return sprite
	
func toggle_track_build_mode(build_mode):
	for node in get_tree().get_nodes_in_group("track_markers"):
		node.toggle_visibility(build_mode)

