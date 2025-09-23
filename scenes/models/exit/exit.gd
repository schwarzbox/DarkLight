class_name Exit

extends Area2D

@export var type: Globals.Models = Globals.Models.EXIT

var _open: bool = false

func start(pos: Vector2) -> void:
	position = pos

	_set_open(false)

func _process(_delta: float) -> void:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	if !enemies:
		if !_open:
			_set_open(true)
	else:
		if _open:
			_set_open(false)

func _set_open(value: bool) -> void:
	_open = value
	$CollisionShape2D.set_deferred("disabled", !_open)
	if _open:
		$Sprite2D.modulate = Globals.GLOW_COLORS.LOW
		$RadialLight.show()
	else:
		$Sprite2D.modulate = Globals.COLORS.DEFAULT_BLACK
		$RadialLight.hide()

func _on_body_entered(body: Player) -> void:
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH
	body.win(self)
