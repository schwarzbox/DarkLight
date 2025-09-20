class_name Exit

extends Area2D

@export var type: Globals.Models = Globals.Models.EXIT

var _open: bool = false

func start(pos: Vector2) -> void:
	position = pos

	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.modulate = Globals.COLORS.DEFAULT_BLACK

func _process(_delta: float) -> void:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	if !enemies:
		if !_open:
			_open = true
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate = Globals.GLOW_COLORS.LOW


func _on_body_entered(body: Player) -> void:
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH
	body.win(self)
