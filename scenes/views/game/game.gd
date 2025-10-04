extends View

signal main_audio_paused
signal main_audio_resumed

var _player: Player = null
var _labirinth: View = null
var _level: int = 0

var _upgrade_button_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	# setup upgrade radio buttons
	for button: Button in [
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shoot,
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Strike,
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shield
	]:
		button.set_button_group(_upgrade_button_group)
	_upgrade_button_group.allow_unpress = true

	_setup()

func _setup() -> void:
	_level = 0
	_labirinth = Globals.LABIRINTH_SCENE.instantiate()
	_player = Globals.PLAYER_SCENE.instantiate()

	$CanvasLayer.show()
	$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = true

	# call _start(_labirinth) to skip Upgrades screen
	_start(_labirinth)


func _start(view: Node) -> void:
	main_audio_paused.emit()

	_level += 1
	view.connect("view_restarted", _on_view_restarted)
	view.connect("view_changed", _on_view_changed)
	view.connect("view_exited", _on_view_exited)
	add_world_child(view)

	# update upgrade radio buttons
	for button: UIButton in _upgrade_button_group.get_buttons():
		button.set_pressed_no_signal(false)

	if _player.get_shoot_count() >= Globals.MAX_SHOOT_COUNT:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shoot.disabled = true
	else:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shoot.disabled = false

	if _player.get_strike_force_step() >= Globals.MAX_STRIKE_FORCE_STEP:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Strike.disabled = true
	else:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Strike.disabled = false

	if _player.get_shield_count() >= Globals.MAX_SHIELD_COUNT:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shield.disabled = true
	else:
		$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shield.disabled = false

	# player setup in view
	view.start(_level, _player)

	if is_world_has_children():
		$CanvasLayer.hide()

func _restart(view: Node) -> void:
	view.remove_models_child(_player)
	view.restart(_player)

func _change(view: Node) -> void:
	main_audio_resumed.emit()

	if _level >= Globals.LEVEL_COUNT:
		# show score view
		view_changed.emit(view)
	else:
		# save player
		view.remove_models_child(_player)
		# clear view
		remove_world_child(view)
		view.queue_free()
		# initialize new labirinth
		_labirinth = Globals.LABIRINTH_SCENE.instantiate()

		# show upgrades screen
		$CanvasLayer.show()
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = true

func _on_view_started() -> void:
	_set_transition(_start, _labirinth)

func _on_view_restarted(view: Node) -> void:
	_set_transition(_restart, view)

func _on_view_changed(view: Node) -> void:
	_set_transition(_change, view)

func _on_view_exited(_view: Node) -> void:
	main_audio_resumed.emit()

	Globals.SCORES.reset_game_time()
	# transit to main
	view_exited.emit(self)

func _on_back_pressed() -> void:
	Globals.SCORES.reset_game_time()
	_set_transition(view_exited.emit, self)

func _on_shoot_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_player.set_shoot_count(Globals.SHOOT_COUNT_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = false
	else:
		_player.set_shoot_count(-Globals.SHOOT_COUNT_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = true

	$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shoot.icon = Globals.UPGRADE_ICONS["shoot"][
		_player.get_shoot_count()
	]

func _on_strike_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_player.set_strike_force_step(Globals.STRIKE_FORCE_STEP_DIFF)
		_player.set_max_strike_force(Globals.MAX_STRIKE_FORCE_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = false
	else:
		_player.set_strike_force_step(-Globals.STRIKE_FORCE_STEP_DIFF)
		_player.set_max_strike_force(-Globals.MAX_STRIKE_FORCE_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = true

	$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Strike.icon = Globals.UPGRADE_ICONS["strike"][
		int(_player.get_strike_force_step())
	]

func _on_shield_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_player.set_shield_count(Globals.SHIELD_COUNT_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = false
	else:
		_player.set_shield_count(-Globals.SHIELD_COUNT_DIFF)
		$CanvasLayer/UpgradesContainer/VBoxContainer/Play.disabled = true

	$CanvasLayer/UpgradesContainer/VBoxContainer/HBoxContainer/Shield.icon = Globals.UPGRADE_ICONS["shield"][
		int(_player.get_shield_count())
	]
