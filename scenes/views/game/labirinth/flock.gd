extends Node2D

var steer_force: float = Globals.FLOCK_STEER_FORCE
var alignment_force: float = Globals.FLOCK_ALIGNMENT_FORCE
var cohesion_force: float = Globals.FLOCK_COHESION_FORCE
var separation_force: float = Globals.FLOCK_SEPARATION_FORCE

func _ready() -> void:
	prints(name, "ready")

func _process(_delta: float) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var cohesion_vector: Vector2 = Vector2.ZERO
	var alignment_vector: Vector2 = Vector2.ZERO

	for enemy: Enemy in enemies:
		cohesion_vector += enemy.global_position
		alignment_vector += enemy._linear_velocity

	cohesion_vector /= enemies.size()
	alignment_vector /= enemies.size()
	for enemy: Enemy in enemies:
		var separation_vector: Vector2 = Vector2.ZERO

		var closest_enemies: Dictionary = enemy.get_closest_enemies()
		for id: int in closest_enemies:
			var closest: Enemy = closest_enemies[id]
			var difference: Vector2 = enemy.global_position - closest.global_position
			separation_vector += difference.normalized() / difference.length()

		if closest_enemies.size():
			separation_vector /= closest_enemies.size()

		var linear_acceleration: Vector2 = enemy.get_linear_acceleration()
		linear_acceleration += enemy.steer(cohesion_vector - enemy.global_position, steer_force) * cohesion_force
		linear_acceleration += enemy.steer(alignment_vector, steer_force) * alignment_force
		linear_acceleration += enemy.steer(separation_vector, steer_force) * separation_force
		enemy.set_linear_acceleration(linear_acceleration)

func start(level: int) -> void:
	separation_force = Globals.SEPARATION_FORCES[level]
