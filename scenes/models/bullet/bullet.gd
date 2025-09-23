class_name Bullet

extends AnimatableBody2D

signal blasted
signal died

@export var type: Globals.Models = Globals.Models.BULLET

var _force: float = 1024.0
var _linear_velocity: Vector2 = Vector2.ZERO
var _linear_acceleration: Vector2 = Vector2.ZERO

var _blast_targets: Dictionary = {}

var _damage: int = 1

func _ready() -> void:
	sync_to_physics = false

	add_to_group("bullet")

	$Body.connect("destroyed", _on_body_destroyed)
	$Body.connect("self_destroyed", _on_body_self_destroyed)

	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.BULLET_SCALE_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	$TrailParticles.emitting = false
	$TrailParticles.fixed_fps = Globals.FIXED_FPS

	# set blast radius
	$BlastRadius/CollisionShape2D.shape.radius = Globals.BULLET_BLAST_RADIUS

	# hide radial light
	$RadialLight.hide()

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
	var velocity_length_squared: float = _linear_velocity.length_squared()

	if velocity_length_squared < Globals.BULLET_STRIKE_FORCE_SQUARED:
		$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE
		$TrailParticles.emitting = false
		$RadialLight.hide()
	else:

		$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH
		$TrailParticles.emitting = true
		$RadialLight.show()

	var collision: KinematicCollision2D = move_and_collide(_linear_velocity * delta)
	# collide
	if collision:
		var collider: Node2D = collision.get_collider()
		if is_instance_of(collider, Enemy):
			var enemy: Enemy = collider
			if velocity_length_squared < Globals.BULLET_STRIKE_FORCE_SQUARED:
				if !enemy.is_dead():
					enemy.hit(_damage)
					hit(enemy.get_damage())
			else:
				if !enemy.is_dead():
					enemy.hit(_damage)
					# set particles
					$ExplodeParticles.amount = $ExplodeParticles.amount * 2
					$ExplodeParticles.emission_sphere_radius = $ExplodeParticles.emission_sphere_radius * 8
					$ExplodeParticles.initial_velocity_max = $ExplodeParticles.initial_velocity_max * 2
					$ExplodeParticles.scale_amount_min = $ExplodeParticles.scale_amount_min * 2
					$ExplodeParticles.scale_amount_max = $ExplodeParticles.scale_amount_max * 2
					hit(enemy.get_damage())
					# emit shock wave
					blasted.emit(global_position)
					for id: int in _blast_targets:
						enemy = _blast_targets[id]
						if !enemy.is_dead():
							var dir: Vector2 = global_position.direction_to(enemy.position)
							enemy.set_linear_velocity(
								enemy.get_linear_velocity() + dir * _linear_velocity.length()
							)
							get_tree().create_timer(Globals.BULLET_BLAST_DELAY).timeout.connect(
								func() -> void:
									enemy.set_dead_audio_volume(-_blast_targets.size())
									enemy.hit(_damage)
							)
		elif is_instance_of(collider, Wall):
			if velocity_length_squared < Globals.BULLET_STRIKE_FORCE_SQUARED:
				$Body.self_destroy()
			else:
				set_linear_velocity(_linear_velocity.bounce(collision.get_normal()))

	# destroy
	if velocity_length_squared < Globals.BULLET_MIN_FORCE_SQUARED:
		$Body.self_destroy()

func start(
	pos: Vector2,
	dir: float,
	strike_force: float = 0.0,
) -> void:
	position = pos
	rotation = dir
	_force += strike_force

	set_linear_velocity(Vector2(_force, 0).rotated(rotation))


func hit(damage: int) -> void:
	$Body.hit(damage)

func is_dead() -> bool:
	return $Body.is_destroyed()

func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel

func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)


func _on_body_destroyed() -> void:
	var _tween: Tween = create_tween()
	$ExplodeParticles.emitting = true
	_tween.tween_property(self, "scale", Vector2.ZERO, Globals.BULLET_SCALE_DELAY)
	_tween.tween_callback(
		func() -> void:
			died.emit(self)
			queue_free()
	)

func _on_body_self_destroyed() -> void:
	var _tween: Tween = create_tween()
	$ExplodeParticles.emitting = true
	_tween.tween_property(self, "scale", Vector2.ZERO, Globals.BULLET_SCALE_DELAY)
	_tween.tween_callback(func() -> void: queue_free())


func _on_blast_radius_body_entered(body: Enemy) -> void:
	_blast_targets[body.get_instance_id()] = body


func _on_blast_radius_body_exited(body: Enemy) -> void:
	_blast_targets.erase(body.get_instance_id())
