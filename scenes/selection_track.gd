extends Path3D

var first: Point = null
var second: Point = null

@export var camera: Camera3D

func _init() -> void:
	curve.clear_points()

func update(point: Point) -> void:
	if point == null:
		return
	if len(point.connections) >= 1:
		first = point.connections[0].start
		second = point
	if first == null or second == null:
		return
	$Line2D.clear_points()
	curve.clear_points()
	curve.add_point(first.position, first.vector_in, first.vector_out)
	curve.add_point(second.position, second.vector_in, second.vector_out)
	for p in curve.get_baked_points():
		if(!camera.is_position_behind(p)):
			$Line2D.add_point(camera.unproject_position(p))

func render() -> MeshInstance3D:
	var combiner: CSGCombiner3D = find_child("CSGCombiner3D")
	var meshes = combiner.get_meshes()
	var meshInstance := MeshInstance3D.new()
	var arrayMesh = meshes[1]
	meshInstance.mesh = arrayMesh
	var material = combiner.get_child(0).material
	meshInstance.material_override = material
	return meshInstance

func _on_character_on_move() -> void:
	update(second)
