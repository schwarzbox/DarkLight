class_name Player

extends AnimatableBody2D

signal bullet_added
signal bullet_removed
signal bullet_blasted

signal died
signal won

signal strike_initiated
signal strike_updated
signal strike_finished

@export var type: Globals.Models = Globals.Models.PLAYER

var sprite_size: Vector2

var _force: float = 256.0
var _linear_velocity: Vector2 = Vector2.ZERO:
	set = set_linear_velocity
var _dump: bool = false:
	get = is_dump,
	set = set_dump
var _linear_acceleration: Vector2 = Vector2.ZERO

var _win: bool = false:
	get = is_win,
	set = set_win

var _is_shoot: bool = false

var _orb_targets: Dictionary = {}

var _shoot_count: int = Globals.MIN_SHOOT_COUNT:
	get = get_shoot_count,
	set = set_shoot_count

var _is_strike: bool = false
var _strike_force: float = 0
var _strike_force_step: float = Globals.MIN_STRIKE_FORCE_STEP:
	get = get_strike_force_step,
	set = set_strike_force_step
var _max_strike_force: float = Globals.MIN_MAX_STRIKE_FORCE:
	get = get_max_strike_force,
	set = set_max_strike_force

var _shield_count: int = Globals.MIN_SHIELD_COUNT:
	get = get_shield_count,
	set = set_shield_count
var _is_shield: bool = false
var _shield_target: Enemy = null

var _shape_tween: Tween
var _heart_beat_tween: Tween
var _strike_tween: Tween
var _win_tween: Tween

var _damage: int = 1

func _ready() -> void:
	prints(name, "ready")
	sync_to_physics = false

	$ShootTimer.wait_time = Globals.PLAYER_SHOOT_DELAY
	$ShootTimer.connect("timeout", func() -> void: _is_shoot = false)
	$ShieldTimer.wait_time = Globals.PLAYER_SHIELD_DELAY
	$ShieldTimer.connect("timeout", func() -> void: _is_shield = false)

	$Body.connect("destroyed", _on_body_destroyed)
	$Body.connect("hp_changed", _on_body_hp_changed)

	sprite_size = $Sprite2D.texture.get_size()
	$Sprite2D.modulate = Globals.GLOW_COLORS.MIDDLE

	$ExplodeParticles.emitting = false
	$ExplodeParticles.lifetime = Globals.PLAYER_DIED_DELAY
	$ExplodeParticles.fixed_fps = Globals.FIXED_FPS
	$ExplodeParticles.one_shot = true

	$HiiParticles.emitting = false
	$HiiParticles.lifetime = Globals.PLAYER_HIT_DELAY
	$HiiParticles.fixed_fps = Globals.FIXED_FPS
	$HiiParticles.one_shot = true


func _process(delta: float) -> void:
	if is_dead() || is_win():
		return

	# dump
	set_linear_velocity(_linear_velocity - _linear_velocity * delta)
	# if on the trap area
	if is_dump():
		set_linear_velocity(_linear_velocity - _linear_velocity * delta)

	_linear_acceleration.x += Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_linear_acceleration.y += Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")

	set_linear_velocity(_linear_velocity + _linear_acceleration.normalized() * _force * delta)

	# reset
	_linear_acceleration = Vector2()

	# ray
	var collision_count: int = $ShapeCast2D.get_collision_count()
	for index: int in collision_count:
		var collider: Node2D = $ShapeCast2D.get_collider(index)
		if is_instance_of(collider, Enemy):
			var collision_point: Vector2 = $ShapeCast2D.get_collision_point(index)
			var collision_normal: Vector2 = $ShapeCast2D.get_collision_normal(index)
			collider.avoid_light(collision_point.bounce(collision_normal))


	# collision
	var collision: KinematicCollision2D = move_and_collide(_linear_velocity * delta)
	if collision:
		var collider: Node2D = collision.get_collider()
		var normal: Vector2 = collision.get_normal()
		# Collisions with Enemy handled by HitRange
		if is_instance_of(collider, Wall):
			# reduce bounce when player collide with wall
			set_linear_velocity(_linear_velocity.bounce(normal) / 2)
		elif is_instance_of(collider, Orb):
			if !collider.is_dead():
				var orb: Orb = collider
				collider.hit(_damage)
				$Body.regenerate(orb.get_bonus())
				$TakeAudio.play()

	# rotate
	var angle: float = global_position.angle_to_point(get_global_mouse_position())
	rotation = lerp_angle(rotation, angle, 0.1)

	_shoot()

	_shield()

	_collect()


func start(pos: Vector2, shape_cast_max_results: int) -> void:
	position = pos
	$ShapeCast2D.max_results = shape_cast_max_results
	_update_shape()

	# reset player
	strike_finished.emit()
	modulate = Color.WHITE
	set_win(false)

func hit(damage: int = 1) -> void:
	$Body.hit(damage)

func get_hp() -> int:
	return $Body.get_hp()

func set_hp(value: int) -> void:
	$Body.set_hp(value)

func is_win() -> bool:
	return _win

func set_win(value: bool) -> void:
	_win = value

func is_dead() -> bool:
	return $Body.is_destroyed()


func is_dump() -> bool:
	return _dump

func set_dump(value: bool) -> void:
	_dump = value

func set_linear_velocity(vel: Vector2) -> void:
	_linear_velocity = vel

func apply_force(pos: Vector2, multiplier: float = 1.0) -> void:
	rotation = get_global_position().angle_to_point(pos)
	_linear_acceleration += Vector2(_force * multiplier, 0).rotated(rotation)

#region Upgrades
func get_shoot_count() -> int:
	return _shoot_count

func set_shoot_count(value: int) -> void:
	_shoot_count += value
	_shoot_count = clamp(_shoot_count, Globals.MIN_SHOOT_COUNT, Globals.MAX_SHOOT_COUNT)

func get_strike_force_step() -> float:
	return _strike_force_step

func set_strike_force_step(value: float) -> void:
	_strike_force_step += value
	_strike_force_step = clamp(_strike_force_step, Globals.MIN_STRIKE_FORCE_STEP, Globals.MAX_STRIKE_FORCE_STEP)

func get_max_strike_force() -> float:
	return _max_strike_force

func set_max_strike_force(value: float) -> void:
	_max_strike_force += value
	_max_strike_force = clamp(_max_strike_force, Globals.MIN_MAX_STRIKE_FORCE, Globals.MAX_MAX_STRIKE_FORCE)


func get_shield_count() -> int:
	return _shield_count

func set_shield_count(value: int) -> void:
	_shield_count += value
	_shield_count = clamp(_shield_count, Globals.MIN_SHIELD_COUNT, Globals.MAX_SHIELD_COUNT)
#endregion

func win(body: Exit) -> void:
	set_win(true)

	if !$WinAudio.is_playing():
		$WinAudio.play()

	if _win_tween:
		_win_tween.kill()

	_win_tween = create_tween()
	_win_tween.tween_property(self, "modulate:a", 0.0, Globals.PLAYER_WIN_DELAY)
	_win_tween.parallel().tween_property(self, "_linear_velocity", Vector2.ZERO, Globals.PLAYER_WIN_DELAY / 2)
	_win_tween.parallel().tween_property(self, "position", body.global_position, Globals.PLAYER_WIN_DELAY / 2)
	_win_tween.tween_callback(func() -> void: won.emit())

func _shoot() -> void:
	if Input.is_action_pressed("ui_right_mouse"):
		if !_strike_force:
			strike_initiated.emit()

		_is_strike = true
		_strike_force += _strike_force_step
		_strike_force = clamp(_strike_force, 0, _max_strike_force)
		if _strike_force < _max_strike_force:
			if !$StrikeAudio.is_playing():
				$StrikeAudio.play()
	if (
		Input.is_action_pressed("ui_left_mouse")
		|| Input.is_action_just_released("ui_right_mouse")
	):
		if !_is_shoot:
			_is_shoot = true
			var bullet_position: Vector2 = $BulletMarker2D.global_position
			if _is_strike:
				var bullet: Bullet = Globals.BULLET_SCENE.instantiate()
				bullet.start(bullet_position, rotation, _strike_force)
				bullet.connect("blasted", _on_bullet_blasted)
				bullet.connect("died", _on_bullet_died)
				bullet_added.emit(bullet)
				# self hit to produce bullet
				hit(_damage)

			else:
				for i: int in _shoot_count:
					var bullet: Bullet = Globals.BULLET_SCENE.instantiate()
					var dispersions: Array = Globals.BULLET_DISPERSIONS[_shoot_count][i]
					var min_dispersion: float = dispersions[0]
					var max_dispersion: float = dispersions[1]
					var random_dispersion: float = randf_range(min_dispersion, max_dispersion)

					bullet.start(bullet_position, rotation + random_dispersion)
					bullet.connect("blasted", _on_bullet_blasted)
					bullet.connect("died", _on_bullet_died)
					bullet_added.emit(bullet)
					# self hit to produce bullet
					hit(_damage)

			$ShootAudio.play()
			$ShootTimer.start()

			# player kick
			if _strike_force:
				@warning_ignore("integer_division")
				var kick_force: float  = clampf(
					_strike_force, 0, Globals.PLAYER_MAX_SHOOT_KICK_FORCE
				)
				set_linear_velocity(
					_linear_velocity - Vector2(kick_force, 0).rotated(rotation)
				)


		_is_strike = false

		if _strike_force:
			if _strike_tween:
				_strike_tween.kill()
			_strike_tween = create_tween()
			var ratio: float = float(_strike_force) / float(_max_strike_force)
			_strike_tween.tween_property(self, "_strike_force", 0, ratio / 4)
			_strike_tween.tween_callback(func() -> void: strike_finished.emit())

	if _strike_force:
		strike_updated.emit(float(_strike_force) / float(_max_strike_force) * 100.0)

func _shield() -> void:
	if _shield_count > 0 && _shield_target && !_is_shield:
		_is_shield = true

		for i: int in range(_shield_count):
			var shield: Bullet = Globals.BULLET_SCENE.instantiate()
			shield.start(position, rotation, 0)
			shield.set_linear_velocity(Vector2.ZERO)
			var shield_markers: Array[Node] = $ShieldMarkers.get_children()
			var direction: Vector2 = shield_markers[i].global_position
			shield.apply_force(direction, Globals.PLAYER_SHIELD_FORCE_MULTIPLIER)
			bullet_added.emit(shield)

		$ShieldAudio.play()
		$ShieldTimer.start()

func _collect() -> void:
	for orb: Orb in _orb_targets.values():
		orb.apply_force(global_position, Globals.PLAYER_ORB_FORCE_MULTIPLIER)

func _update_shape() -> void:
	if _shape_tween:
		_shape_tween.kill()

	var diff: float = $Body.hp_ratio()
	_shape_tween = create_tween()
	_shape_tween.tween_property(
		$Sprite2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)
	_shape_tween.parallel().tween_property(
		$CollisionShape2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)
	_shape_tween.parallel().tween_property(
		$HitRange/CollisionShape2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)

	if $Body.is_damaged():
		_heart_beat()
	else:
		if _heart_beat_tween:
			_heart_beat_tween.kill()

func _heart_beat() -> void:
	if _heart_beat_tween:
		_heart_beat_tween.kill()

	var diff: float = $Body.hp_ratio()
	_heart_beat_tween = create_tween().set_loops()
	_heart_beat_tween.tween_property(
		$Sprite2D, "scale", Vector2(diff - 0.2, diff - 0.2), Globals.PLAYER_SCALE_DELAY
	)
	_heart_beat_tween.parallel().tween_property(
		$CollisionShape2D, "scale", Vector2(diff - 0.2, diff - 0.2), Globals.PLAYER_SCALE_DELAY
	)
	_heart_beat_tween.parallel().tween_property(
		$HitRange/CollisionShape2D, "scale", Vector2(diff - 0.2, diff - 0.2), Globals.PLAYER_SCALE_DELAY
	)
	_heart_beat_tween.tween_interval(0.1)
	_heart_beat_tween.tween_property(
		$Sprite2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)
	_heart_beat_tween.parallel().tween_property(
		$CollisionShape2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)
	_heart_beat_tween.parallel().tween_property(
		$HitRange/CollisionShape2D, "scale", Vector2(diff, diff), Globals.PLAYER_SCALE_DELAY
	)

func _on_body_destroyed() -> void:
	# kill tweens
	if _shape_tween:
		_shape_tween.kill()
	if _heart_beat_tween:
		_heart_beat_tween.kill()
	if _strike_tween:
		_strike_tween.kill()
	if _win_tween:
		_win_tween.kill()
	# hide strike cursor
	strike_finished.emit()
	# hide default cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# hide light
	$ConeLight.hide()

	var tween: Tween = create_tween()
	$DeadAudio.play()
	$ExplodeParticles.emitting = true
	tween.tween_property(self, "modulate:a", 0.0, Globals.PLAYER_DIED_DELAY)
	tween.parallel().tween_property($Sprite2D, "scale", Vector2.ZERO, Globals.PLAYER_DIED_DELAY / 2)
	tween.parallel().tween_property($CollisionShape2D, "scale", Vector2.ZERO, Globals.PLAYER_DIED_DELAY / 2)
	tween.parallel().tween_property($HitRange/CollisionShape2D, "scale", Vector2.ZERO, Globals.PLAYER_SCALE_DELAY / 2)
	tween.tween_callback(
		func() -> void:
			died.emit()
			queue_free()
	)

func _on_body_hp_changed(_value: int) -> void:
	_update_shape()

func _on_bullet_died(child: Bullet) -> void:
	bullet_removed.emit(child)

func _on_bullet_blasted(pos: Vector2) -> void:
	bullet_blasted.emit(pos, $Camera2D.global_position)

func _on_collect_range_body_entered(body: Orb) -> void:
	_orb_targets[body.get_instance_id()] = body

func _on_collect_range_body_exited(body: Orb) -> void:
	_orb_targets.erase(body.get_instance_id())

func _on_shield_range_body_entered(body: Enemy) -> void:
	_shield_target = body

func _on_shield_range_body_exited(_body: Enemy) -> void:
	_shield_target = null

func _on_hit_range_body_entered(body: Enemy) -> void:
	if is_dead() || is_win():
		return

	if !body.is_dead():
		# enemy not damaged
		hit(body.get_damage())
		# player kick
		var kick_force: float  = clampf(
			body.get_linear_velocity().length(), 0, Globals.PLAYER_MAX_HIT_KICK_FORCE
		)
		set_linear_velocity(
			_linear_velocity - Vector2(kick_force, 0).rotated(rotation)
		)
		if !$HitAudio.is_playing():
			$HitAudio.play()
		$HiiParticles.emitting = true
