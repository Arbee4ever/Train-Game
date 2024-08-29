extends PathFollow3D
class_name Train

enum DIRECTION {FORWARDS = 1, BACKWARDS = -1}

@export var direction: DIRECTION = DIRECTION.FORWARDS:
	set(dir):
		direction = dir
		$Mesh.rotation_degrees.y = 90 * (direction + 1)
@export var target_speed = 50
@export var speed = 0
var degRotation = 0

func _physics_process(delta: float) -> void:
	if speed != target_speed:
		speed = speed - 0.05 * (speed - target_speed)
	if progress_ratio >= 1:
		direction = DIRECTION.BACKWARDS
	elif progress_ratio <= 0:
		direction = DIRECTION.FORWARDS
	progress += speed * direction * delta

func stop():
	if target_speed == 0:
		target_speed = 50
	else:
		target_speed = 0


func _on_click(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("action"):
		var char: Character = camera.get_parent()
		char.reparent($Mesh)
		char.locked = true
		char.rotation = Vector3(0, PI, 0)
		char._total_pitch = 0.0
		char.position = Vector3(0, 6, -2)
