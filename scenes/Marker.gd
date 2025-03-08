extends Node3D
@export var point: Point

signal input_event

func _ready() -> void:
	visible = false
	point.on_commit.connect(init)
	
func init() -> void:
	visible = Globals.markers_vis
	move(point)
	point.on_move.connect(move)
	point.on_in_change.connect(move)
	point.on_out_change.connect(move)

func _process(delta: float) -> void:
	var character = get_node_or_null("/root/Controller/Character")
	if character != null:
		var distance = position.distance_to(character.position)
		$Area3D/CollisionShape3D.shape.radius = distance * 0.1

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	input_event.emit(camera, event, event_position, normal, shape_idx, point)

func toggle_vis():
	visible = Globals.markers_vis

func remove():
	queue_free()

func move(p: Point):
	position = p.position
	$Label3D.text = str(position)
	$Label3D2.text = str(p.vector_in)
	$Label3D3.text = str(p.vector_out)
