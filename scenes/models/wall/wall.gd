class_name Wall

extends StaticBody2D


@export var type: Globals.Models = Globals.Models.WALL

func start(pos: Vector2) -> void:
	position = pos
