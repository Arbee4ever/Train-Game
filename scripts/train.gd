extends MeshInstance3D

func _ready():
	set_physics_process(true)

var direction = 1;
func _physics_process(delta):
	var parent: PathFollow3D = get_parent()
	if parent.progress_ratio >= 1:
		direction = -1
	elif parent.progress_ratio <= 0:
		direction = 1

	parent.progress += 80.0 * direction * delta
