class_name Enemy

extends AnimatableBody2D

@export var type: Globals.Models = Globals.Models.ENEMY

var sprite_size: Vector2

var _force: float = 256.0

var _linear_velocity: Vector2 = Vector2.ZERO:
	set = set_linear_velocity
var _linear_acceleration: Vector2 = Vector2.ZERO:
	get = get_linear_acceleration

var _target: Player
var _level: int  = 1

var _closest_enemies: Dictionary = {}:
	get = get_closest_enemies

var _damage: int = 10:
	get = get_damage


func _ready() -> void:
	sync_to_physics = false

	add_to_group("enemy")

	$Body.connect("destroyed", _on_body_destroyed)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.HIGH

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.ENEMY_SCALE_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	$TrailParticles.emitting = true
	$TrailParticles.fixed_fps = Globals.FIXED_FPS

func _process(delta: float) -> void:
	if is_dead():
		return

	# dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)

	# move
	var force: float = _force
	if _target:
		var angle: float = global_position.angle_to_point(_target.get_global_position())
		rotation = lerp_angle(rotation, angle, 1.0)
		var distance: float = global_position.distance_squared_to(_target.position)
		if distance < Globals.ENEMY_CATCH_PLAYER_SQUARED_DISTANCE:
			force *= Globals.CATCH_FORCE_MULTIPLIERS[_level]
		elif distance < Globals.ENEMY_SHOOT_PLAYER_SQUARED_DISTANCE:
			if randf() < Globals.ENEMY_CHANCE_TO_SHOOT:
				force *= Globals.SHOOT_FORCE_MULTIPLIERS[_level]
	else:
		var angle: float = randf_range(0, TAU)
		rotation = lerp_angle(rotation, angle, 1.0)

	set_linear_acceleration(
		_linear_acceleration + Vector2(force, 0).rotated(rotation)
	)

	set_linear_velocity(_linear_velocity + _linear_acceleration * delta)

	# reset
	_linear_acceleration = Vector2()

	# collision
	var collision: KinematicCollision2D = move_and_collide(_linear_velocity * delta)
	if collision:
		var collider: Node2D = collision.get_collider()
		if is_instance_of(collider, Wall):
			set_linear_velocity(_linear_velocity.bounce(collision.get_normal()))

func start(pos: Vector2, level: int) -> void:
	position = pos
	_level = level

	# increase target radius
	$TargetRange/CollisionShape2D.shape.radius = Globals.TARGET_SHAPE_RADIUS[level]

func hit(damage: int) -> void:
	$Body.hit(damage)

func set_dead_audio_volume(value: int) -> void:
	$DeadAudio.volume_db = value

func is_dead() -> bool:
	return $Body.is_destroyed()

func get_linear_acceleration() -> Vector2:
	return _linear_acceleration

func set_linear_acceleration(acc: Vector2) -> void:
	_linear_acceleration = acc

func get_linear_velocity() -> Vector2:
	return _linear_velocity

func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel

func get_damage() -> int:
	return _damage

func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	set_linear_acceleration(
		_linear_acceleration + Vector2(_force * multiplier, 0).rotated(rotation)
	)

func steer(value: Vector2, steer_force: float) -> Vector2:
	var force: Vector2 = value.normalized() * _force - _linear_velocity
	return force.normalized() * steer_force

func get_closest_enemies() -> Dictionary:
	return _closest_enemies

func avoid_light(pos: Vector2) -> void:
	apply_force(pos, Globals.ENEMY_AVOID_LIGHT_FORCE_MULTIPLIER)

func _on_body_destroyed() -> void:
	var tween: Tween = create_tween()
	$DeadAudio.play()
	$ExplodeParticles.emitting = true
	tween.tween_property(self, "scale", Vector2.ZERO, Globals.ENEMY_SCALE_DELAY)
	tween.tween_callback(func() -> void: queue_free())

func _on_target_range_body_entered(body: Player) -> void:
	_target = body

func _on_target_range_body_exited(_body: Player) -> void:
	_target = null

func _on_separation_range_body_entered(body: Enemy) -> void:
	if body != self:
		_closest_enemies[body.get_instance_id()] = body

func _on_separation_range_body_exited(body: Enemy) -> void:
	if body != self:
		_closest_enemies.erase(body.get_instance_id())
