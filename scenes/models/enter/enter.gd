class_name Enter

extends Node2D

@export var type: Globals.Models = Globals.Models.ENTER

func start(pos: Vector2) -> void:
	position = pos

	$Sprite2D.modulate = Globals.COLORS.DEFAULT_WHITE
