class_name Point
extends Resource

signal on_move()
signal on_in_change()
signal on_out_change()
signal on_commit()

@export var id := -1
@export var position := Vector3.ZERO:
	set(newPosition):
		position = newPosition
		on_move.emit(self)
@export var connections: Array[Track] = []
@export var vector_in := Vector3.ZERO:
	set(newVector):
		vector_in = newVector
		on_in_change.emit(self)
@export var vector_out := Vector3.ZERO:
	set(newVector):
		vector_out = newVector
		on_out_change.emit(self)

func _init(newPos: Vector3) -> void:
	position = newPos

func commit():
	on_commit.emit()