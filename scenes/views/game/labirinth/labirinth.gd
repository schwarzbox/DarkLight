extends View

var _level: int = 0
var _enemies_per_level: int = 25

var _level_tween: Tween
var _pause_tween: Tween
var _game_over_tween: Tween

var _state: Dictionary = {}

@onready var _ui_containers: Dictionary = {
	"level": $CanvasLayer/LevelContainer,
	"game_over": $CanvasLayer/GameOverContainer,
	"pause": $CanvasLayer/PauseContainer
}
@onready var _audio_stream_players: Array[AudioStreamPlayer] = [
	$AudioStreamPlayer1,
	$AudioStreamPlayer2,
	$AudioStreamPlayer3,
]
@onready var _audio_stream_player: AudioStreamPlayer =  _audio_stream_players.pick_random()

func _ready() -> void:
	prints(name, "ready")

	_audio_stream_player.play()

	_show_ui_container()

	for node: Control in [
		$CanvasLayer/PauseContainer/VBoxContainer/Resume,
		$CanvasLayer/PauseContainer/VBoxContainer/Restart,
		$CanvasLayer/PauseContainer/VBoxContainer/Back
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				pause()

func add_models_child(child: Node2D) -> void:
	$World.add_models_child(child)

func remove_models_child(child: Node2D) -> void:
	$World.remove_models_child(child)

func start(level: int, player: Player) -> void:
	_level = level
	_show_level()

	var enemy_count: int = _level * _enemies_per_level
	$World.set_models(_level, enemy_count)

	player.connect("strike_initiated", _on_player_strike_initiated)
	player.connect("strike_updated", _on_player_strike_updated)
	player.connect("strike_finished", _on_player_strike_finished)

	player.connect("bullet_added", add_models_child)
	player.connect("bullet_blasted", _on_player_bullet_blasted)
	player.connect("bullet_removed", _on_player_bullet_removed)
	player.connect("died", _on_player_died)
	player.connect("won",_on_player_won)
	$World.set_player(player, enemy_count)

	# save state
	_state["player_hp"] = player.get_hp()

func restart(player: Player) -> void:
	_show_level()

	# delete enemies
	get_tree().call_group("enemy", "queue_free")

	# create enemies
	var enemy_count: int = _level * _enemies_per_level
	$World.create_enemies(_level, enemy_count)

	# load state
	var player_hp: int = _state.get("player_hp", player.get_hp())
	player.set_hp(player_hp)

	$World.set_player(player, enemy_count)

func pause() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		_show_pause()
	else:
		_hide_pause()

func _show_ui_container(key: String = "", alpha: float = 0.0) -> void:
	for node: Control in _ui_containers.values():
		node.hide()
		node.modulate.a = 0.0

	var ui_container: Control = _ui_containers.get(key)
	if ui_container:
		ui_container.show()
		ui_container.modulate.a = alpha

func _show_level() -> void:
	_show_ui_container("level", 0.0)

	$CanvasLayer/LevelContainer/Label.text = str(_level)

	if _level_tween:
		_level_tween.kill()
	_level_tween = create_tween()
	_level_tween.tween_property($CanvasLayer/LevelContainer, "modulate:a", 1.0, Globals.LABIRINTH_UI_DELAY)
	_level_tween.tween_property($CanvasLayer/LevelContainer, "modulate:a", 0.0, Globals.LABIRINTH_UI_DELAY)
	_level_tween.tween_callback(
		func() -> void:
			$CanvasLayer/LevelContainer.hide()
	)

func _show_pause() -> void:
	_audio_stream_player.stop()

	_show_ui_container("pause", 0.0)

	if _pause_tween:
		_pause_tween.kill()
	_pause_tween = create_tween()
	_pause_tween.tween_property($CanvasLayer/PauseContainer, "modulate:a", 1.0, Globals.LABIRINTH_UI_DELAY)

func _hide_pause() -> void:
	_audio_stream_player.play()

	if _pause_tween:
		_pause_tween.kill()
	_pause_tween = create_tween()
	_pause_tween.tween_property($CanvasLayer/PauseContainer, "modulate:a", 0.0, Globals.LABIRINTH_UI_DELAY)
	_pause_tween.tween_callback(
		func() -> void:
			$CanvasLayer/PauseContainer.hide()
	)

func _on_player_strike_initiated() -> void:
	$CursorLayer/StrikeCursor.show_cursor()

func _on_player_strike_updated(value: float) -> void:
	$CursorLayer/StrikeCursor.set_strike_bar_value(value)

func _on_player_strike_finished() -> void:
	$CursorLayer/StrikeCursor.hide_cursor()

func _on_player_bullet_removed(child: Bullet) -> void:
	if randf() > Globals.ORB_CHANCE_TO_CREATE:
		return

	var orb: Orb = Globals.ORB_SCENE.instantiate()
	add_models_child(orb)
	orb.start(child.global_position)

func _on_player_bullet_blasted(pos: Vector2, camera_pos: Vector2) -> void:
	$World/ShockWave.material.set_shader_parameter("global_position", pos)
	$World/ShockWave.material.set_shader_parameter("camera_position", camera_pos)
	$World/AnimationPlayer.play("Pulse")

func _on_player_won() -> void:
	view_changed.emit(self)

func _on_player_died() -> void:
	_show_ui_container("game_over", 0.0)

	if _game_over_tween:
		_game_over_tween.kill()
	_game_over_tween = create_tween()
	_game_over_tween.tween_property($CanvasLayer/GameOverContainer, "modulate:a", 1.0, Globals.LABIRINTH_UI_DELAY)
	_game_over_tween.tween_property($CanvasLayer/GameOverContainer, "modulate:a", 0.0, Globals.LABIRINTH_UI_DELAY)
	_game_over_tween.parallel().tween_property(_audio_stream_player, "volume_db", -10, Globals.LABIRINTH_UI_DELAY)
	_game_over_tween.tween_callback(
		func() -> void:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			view_exited.emit(self)
	)

func _on_resume_pressed() -> void:
	pause()

func _on_restart_pressed() -> void:
	pause()
	view_restarted.emit(self)

func _on_back_pressed() -> void:
	pause()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_set_transition(
		func(view: View) -> void: view_exited.emit(view), self
	)
