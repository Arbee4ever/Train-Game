#Code from https://www.youtube.com/watch?v=Gfpnxg-jne4
extends MultiMeshInstance3D

@export var distance_between_planks = 1.0:
	set(value):
		distance_between_planks = value
		is_dirty = true
	
var is_dirty = false

@onready var path = get_parent()
 
func _ready() -> void:
	clear_points()
	path.curve_changed.connect(_on_curve_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dirty:
		_update_multimesh()

		is_dirty = false

func _update_multimesh():
	var path_length: float = path.curve.get_baked_length()
	var count = floor(path_length / distance_between_planks)

	var mm: MultiMesh = multimesh
	mm.instance_count = count
	var offset = distance_between_planks/2.0

	for i in range(0, count):
		var _curve_distance = offset + distance_between_planks * i
		var _position = path.curve.sample_baked(_curve_distance, true)

		var _basis = Basis()
		
		var up = Vector3.UP
		var _forward = _position.direction_to(path.curve.sample_baked(_curve_distance + 0.1, true))
		
		_basis.y = up
		_basis.x = _forward.cross(up)
		_basis.z = -_forward
		
		var _transform = Transform3D(_basis, _position)
		mm.set_instance_transform(i, _transform)

func _on_curve_changed():
	is_dirty = true
	
func clear_points():
	path.curve.clear_points()
	is_dirty = true