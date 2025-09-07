extends Node

var _map: Array[Array]

func _ready() -> void:
	prints(name, "ready")

func add_models_child(child: Node2D) -> void:
	$Models.add_child(child)

func remove_models_child(child: Node2D) -> void:
	$Models.remove_child(child)

func set_models(level: int, enemy_count: int) -> void:
	# generate labirinth
	var lab_dimension: Vector2i = Globals.LABIRINTH_DIMENSIONS[level]
	var lab_width: int = lab_dimension.x
	var lab_height: int = lab_dimension.y

	_map = _create_map(lab_width, lab_height, Globals.Models.WALL)
	_generate_labirinth(lab_width, lab_height, 2, 2)

	var trap_count: int = 0
	var enter_position: Vector2
	var exit_position: Vector2

	for y: int in range(0, lab_height):
		for x: int in range(0, lab_width):
			var pos: Vector2 = (
				Vector2(x, y) * Globals.LABIRINTH_TILE_SIZE + Globals.LABIRINTH_TILE_SIZE * 0.5
			)
			if _map[x][y] == Globals.Models.WALL:
				_create_wall(pos)
			if !enter_position:
				if _map[x][y] == Globals.Models.EMPTY:
					_map[x][y] = Globals.Models.ENTER
					enter_position = pos

			@warning_ignore("integer_division")
			if y > lab_height / 2:
				if !exit_position:
					if _map[x][y] == Globals.Models.EMPTY:
						_map[x][y] = Globals.Models.EXIT
						exit_position = pos


			if _map[x][y] == Globals.Models.EMPTY:
				if (
					randf() < Globals.LABIRINTH_TRAP_PROBABILITY
					&& trap_count < Globals.LABIRINTH_TRAP_COUNT
				):
					_map[x][y] = Globals.Models.TRAP
					_create_trap(pos)
					trap_count += 1

	_create_enter(enter_position)
	_create_exit(exit_position)

	create_enemies(level, enemy_count)

func create_enemies(level: int, enemy_count: int) -> void:
	for _i: int in range(enemy_count):
		_create_enemy(level)

	# setup flock
	$Flock.start(level)

func set_player(player: Player, shape_cast_max_results: int) -> void:
	add_models_child(player)
	var enter_position: Vector2 = $Models.get_node("Enter").position
	player.start(enter_position, shape_cast_max_results)

func _create_enemy(level: int) -> void:
	var enemy: Enemy = Globals.ENEMY_SCENE.instantiate()
	add_models_child(enemy)
	var exit_position: Vector2 = $Models.get_node("Exit").position
	enemy.start(
		Vector2(
			randf_range(
				exit_position.x - enemy.sprite_size.x, exit_position.x + enemy.sprite_size.x
			),
			randf_range(
				exit_position.y - enemy.sprite_size.y, exit_position.y + enemy.sprite_size.y
			)
		),
		level
	)

func _create_wall(pos: Vector2) -> void:
	var wall: Wall = Globals.WALL_SCENE.instantiate()
	add_models_child(wall)
	wall.start(pos)

func _create_enter(pos: Vector2) -> void:
	var enter: Enter = Globals.ENTER_SCENE.instantiate()
	add_models_child(enter)
	enter.start(pos)

func _create_exit(pos: Vector2) -> void:
	var exit: Exit = Globals.EXIT_SCENE.instantiate()
	add_models_child(exit)
	exit.start(pos)

func _create_trap(pos: Vector2) -> void:
	var trap: Trap = Globals.TRAP_SCENE.instantiate()
	add_models_child(trap)
	trap.start(pos)

#region Labirinth
func _create_map(wid: int, hei: int, model_type: Globals.Models) -> Array[Array]:
	var map: Array[Array] = []
	for _i: int in range(wid):
		var col: Array = []
		col.resize(hei)
		col.fill(model_type)
		map.append(col)

	return map

func _find_closest(lab_width: int, lab_height: int, x: int, y: int, model_type: Globals.Models) -> int:
	var closest: int  = 0
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			if dx == 0 && dy == 0:
				continue

			var xx: int = x - dx
			var yy: int = y - dy
			if xx >= 0 && xx < lab_width && yy >= 0 && yy < lab_height:
				if _map[xx][yy] == model_type:
					closest += 1
	return closest

func _cut_caves(lab_width: int, lab_height: int) -> void:
	var caves_positions: Array = []
	for y: int in range(0, lab_height):
		for x: int in range(0, lab_width):
			if _map[x][y] == Globals.Models.WALL:
				var closest: int = _find_closest(
					lab_width, lab_height, x, y, Globals.Models.EMPTY
				)
				if closest >= 5:
					caves_positions.append(Vector2(x, y))

	for value: Vector2 in caves_positions:
		_map[value.x][value.y] = Globals.Models.EMPTY

func _cut_dead_ends(lab_width: int, lab_height: int) -> void:
	var dead_ends_positions: Array = []
	for y: int in range(0, lab_height):
		for x: int in range(0, lab_width):
			if _map[x][y] == Globals.Models.EMPTY:
				var closest: int = _find_closest(
					lab_width, lab_height, x, y, Globals.Models.EMPTY
				);
				if closest <= 1:
					dead_ends_positions.append(Vector2(x, y))

	for value: Vector2 in dead_ends_positions:
		_map[value.x][value.y] = Globals.Models.WALL

func _generate_labirinth(lab_width: int, lab_height: int, caves: int = 3, deadends: int = 2) -> void:
	var ix: int = randi_range(1, lab_width - 2)
	var iy: int = randi_range(1, lab_height - 2)

	_map[ix][iy] = Globals.Models.EMPTY

	var to_check: Array = []
	if iy - 2 > 0:
		to_check.append(Vector2i(ix, iy - 2))
	if iy + 2 < lab_height - 1:
		to_check.append(Vector2i(ix, iy + 2))
	if ix - 2 > 0:
		to_check.append(Vector2i(ix - 2, iy))
	if ix + 2 < lab_width - 1:
		to_check.append(Vector2i(ix + 2, iy))

	while to_check.size() > 0:
		var cell: Vector2i = to_check.pick_random()

		ix = cell.x;
		iy = cell.y;

		_map[ix][iy] = Globals.Models.EMPTY

		to_check = to_check.filter(
			func(value: Vector2i) -> bool: return value != cell
		)

		# Clear the cell between them
		var directions: Array = [0, 1, 2, 3]
		while directions.size() > 0:
			var random_direction: int = directions.pick_random()
			match random_direction:
				0:
					if iy - 2 >= 0 && _map[ix][iy - 2] == Globals.Models.EMPTY:
						_map[ix][iy - 1] = Globals.Models.EMPTY
						directions = []
				1:
					if iy + 2 < lab_height &&  _map[ix][iy + 2] == Globals.Models.EMPTY:
						_map[ix][iy + 1] = Globals.Models.EMPTY
						directions = []
				2:
					if ix - 2 >= 0 && _map[ix - 2][iy] == Globals.Models.EMPTY:
						_map[ix - 1][iy] = Globals.Models.EMPTY
						directions = []
				3:
					if ix + 2 < lab_width && _map[ix + 2][iy] == Globals.Models.EMPTY:
						_map[ix + 1][iy] = Globals.Models.EMPTY
						directions = []

			directions = directions.filter(
				func(direction: int) -> bool: return direction != random_direction
			)

			if iy - 2 > 0 && _map[ix][iy - 2] == Globals.Models.WALL:
				to_check.append(Vector2i(ix, iy - 2))
			if iy + 2 < lab_height - 1 && _map[ix][iy + 2] == Globals.Models.WALL:
				to_check.append(Vector2i(ix, iy + 2))
			if ix - 2 > 0 && _map[ix - 2][iy] == Globals.Models.WALL:
				to_check.append(Vector2i(ix - 2, iy))
			if ix + 2 < lab_width - 1 && _map[ix + 2][iy] == Globals.Models.WALL:
				to_check.append(Vector2i(ix + 2, iy))

	for i: int in range(0, deadends):
		_cut_dead_ends(lab_width, lab_height)
	for i: int in range(0, caves):
		_cut_caves(lab_width, lab_height)
	for i: int in range(0, deadends):
		_cut_dead_ends(lab_width, lab_height)
#endregion
