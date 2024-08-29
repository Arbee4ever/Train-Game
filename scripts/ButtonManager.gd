extends VBoxContainer

var path := "res://save.tres"
@onready var network: TrackNetwork = get_node("/root/Controller").network

func _on_save_button_pressed() -> void:
	ResourceSaver.save(network, path)

func _on_load_button_pressed() -> void:
	get_node("/root/Controller").network.points = ResourceLoader.load(path).points
	get_node("/root/Controller").network.tracks = ResourceLoader.load(path).tracks
	get_node("/root/Controller").rebuild_path()


func _on_train_button_pressed() -> void:
	get_node("/root/Controller").add_train()


func _on_train_pause_button_pressed() -> void:
	for train in get_tree().get_nodes_in_group("trains"):
		train.stop()


func _on_speed_input_text_submitted(new_text: String) -> void:
	get_node("/root/Controller").train_target_speed = int(new_text)


func _on_clear_button_pressed() -> void:
	get_node("/root/Controller").network.points = []
	get_node("/root/Controller").network.tracks = []
	get_node("/root/Controller").rebuild_path()
