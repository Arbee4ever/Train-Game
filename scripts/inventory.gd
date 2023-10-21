extends Node2D

var items := {}
var selected_item = ""

var buttonSize = 100

signal item_selected(item)

func _init():
	items["Train Station"] = "res://assets/trainStation.tscn"
	items["Track"] = "res://assets/track.tscn"

func _ready():
	var i = 0
	for item in items:
		var button := Button.new()
		button.text = item
		button.clip_text = true
		button.set_size(Vector2(buttonSize, buttonSize))
		button.set_position(Vector2(0, buttonSize * i))
		button.pressed.connect(self._select_item.bind(items[item]))
		add_child(button)
		i += 1

func _select_item(item):
	item_selected.emit(item)
	for node in get_tree().get_nodes_in_group("tracks"):
		node.toggle_track_build_mode(item == items["Track"])
	selected_item = item
