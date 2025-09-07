class_name Orb

extends AnimatableBody2D

@export var type: Globals.Models = Globals.Models.ORB

var _force: float = 196.0
var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _bonus: int = 10:
	get = get_bonus

func _ready() -> void:
	sync_to_physics = false

	$Body.connect("destroyed", _on_body_destroyed)
	$Body.connect("self_destroyed", _on_body_self_destroyed)

	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	$LifetimeTimer.wait_time = Globals.ORB_DIED_DELAY
	$LifetimeTimer.connect("timeout", self_destroy)
	$LifetimeTimer.start()

	var tween: Tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	tween.tween_interval(0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)

func _process(delta: float) -> void:
	if is_dead():
		return

	# dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)

	# move
	set_linear_velocity(_linear_velocity + _linear_acceleration * delta)

	# reset
	_linear_acceleration = Vector2()

	# move
	var collision: KinematicCollision2D = move_and_collide(_linear_velocity * delta)
	# collide
	if collision:
		var collider: Node2D = collision.get_collider()
		if is_instance_of(collider, Wall):
			set_linear_velocity(_linear_velocity.bounce(collision.get_normal()))

func start(pos: Vector2) -> void:
	position = pos

func hit(damage: int = 1) -> void:
	$Body.hit(damage)

func is_dead() -> bool:
	return $Body.is_destroyed()

func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel

func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)

func apply_impulse(pos: Vector2) -> void:
	rotation = get_global_position().angle_to_point(pos)
	set_linear_velocity(_linear_velocity + Vector2(_force, 0).rotated(rotation))

func get_bonus() -> int:
	return _bonus

func self_destroy() -> void:
	$Body.self_destroy()

func _on_body_destroyed() -> void:
	queue_free()

func _on_body_self_destroyed() -> void:
	var _tween: Tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ZERO, Globals.ORB_SCALE_DELAY)
	_tween.tween_callback(func() -> void: queue_free())
