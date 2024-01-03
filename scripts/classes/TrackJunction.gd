class_name TrackJunction extends Node3D

var neighbours: String

func _init(neighbours, position, rotation):
	self.neighbours = neighbours
	self.position = position
	self.rotation = rotation
