class_name Marker extends Sprite3D

func toggle_visibility(visible):
	self.visible = visible

var track: Track
var point: int

func _ready():
	track = get_parent()

func _on_collider_input_event(camera, event: InputEvent, position, normal, shape_idx):
	if event.is_action_pressed("left_click"):
		get_tree().get_root().get_node("World/Builder").attachTrack(track, point)

func delete():
	self.get_parent().remove_child(self)
