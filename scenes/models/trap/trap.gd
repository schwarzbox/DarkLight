class_name Trap

extends Area2D

@export var type: Globals.Models = Globals.Models.TRAP


func start(pos: Vector2) -> void:
	position = pos


func _on_body_entered(body: Player) -> void:
	body.set_dump(true)


func _on_body_exited(body: Player) -> void:
	body.set_dump(false)
