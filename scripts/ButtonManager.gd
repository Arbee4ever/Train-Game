extends Control

var path := "res://save.tres"
@onready var controller = get_node("/root/Controller")
@onready var network: TrackNetwork = controller.network

func _on_save_button_pressed() -> void:
	ResourceSaver.save(network, path)

func _on_load_button_pressed() -> void:
	network.points = ResourceLoader.load(path).points
	network.tracks = ResourceLoader.load(path).tracks
	controller.rebuild_path()


func _on_train_button_pressed() -> void:
	controller.add_train()


func _on_train_pause_button_pressed() -> void:
	for train in get_tree().get_nodes_in_group("trains"):
		train.stop()


func _on_speed_input_text_submitted(new_text: String) -> void:
	controller.train_target_speed = int(new_text)


func _on_clear_button_pressed() -> void:
	controller.network.points = []
	controller.network.tracks = []
	controller.rebuild_path()


func _on_marker_toggle_button_pressed() -> void:
	Globals.markers_vis = !Globals.markers_vis
	get_tree().call_group("markers", "toggle_vis")
