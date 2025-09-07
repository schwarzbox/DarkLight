extends View

var player: Player = null
var labirinth: View = null
var level: int = 0

var _upgrade_button_group: ButtonGroup = ButtonGroup.new()

var _start_time: int = 0
var _game_time: int = 0

func _ready() -> void:
	prints(name, "ready")

	$CanvasLayer/Menu.show()
	$CanvasLayer/Score.hide()

	# setup upgrade radio buttons
	for button: Button in [
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shoot,
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Strike,
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shield
	]:
		button.set_button_group(_upgrade_button_group)
	_upgrade_button_group.allow_unpress = true

	for node: Control in [
		$CanvasLayer/Menu/VBoxContainer/Play,
		$CanvasLayer/Menu/VBoxContainer/Back,
		$CanvasLayer/Score/VBoxContainer/Back,
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

	_setup()

func _setup() -> void:
	level = 0
	labirinth = Globals.LABIRINTH_SCENE.instantiate()
	player = Globals.PLAYER_SCENE.instantiate()

	$CanvasLayer/Menu/VBoxContainer/Play.disabled = true
	$CanvasLayer.show()

	# call _start(labirinth) to skip UI screen
	_start(labirinth)

func _start(view: Node) -> void:
	# custom mouse image
	var cursor_size: Vector2 = Globals.AIM_IMAGE.get_size()
	Input.set_custom_mouse_cursor(
		Globals.AIM_IMAGE, Input.CursorShape.CURSOR_ARROW, cursor_size / 2
	)

	level += 1
	view.connect("view_restarted", self._on_view_restarted)
	view.connect("view_changed", self._on_view_changed)
	view.connect("view_exited", self._on_view_exited)
	add_world_child(view)

	# update upgrade radio buttons
	for button: UIButton in _upgrade_button_group.get_buttons():
		button.set_pressed_no_signal(false)

	if player.get_shoot_count() >= Globals.MAX_SHOOT_COUNT:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shoot.disabled = true
	else:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shoot.disabled = false

	if player.get_strike_force_step() >= Globals.MAX_STRIKE_FORCE_STEP:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Strike.disabled = true
	else:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Strike.disabled = false

	if player.get_shield_count() >= Globals.MAX_SHIELD_COUNT:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shield.disabled = true
	else:
		$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shield.disabled = false

	# player setup in view
	view.start(level, player)

	# save start time
	_start_time = Time.get_ticks_msec()

	if is_world_has_children():
		$CanvasLayer.hide()


func _change(view: Node) -> void:
	# save player
	view.remove_models_child(player)
	# clear view
	remove_world_child(view)
	view.queue_free()

	# save game time
	_game_time = _game_time + (Time.get_ticks_msec() - _start_time)
	# convert _game_time to seconds
	@warning_ignore("integer_division")
	_game_time = int(_game_time) / 1000 if int(_game_time) > 0 else _game_time

	if level >= Globals.LEVELS_COUNT:
		$CanvasLayer/Menu.hide()
		$CanvasLayer/Score.show()
		$CanvasLayer/Score/VBoxContainer/NameEdit.grab_focus()
		_show_scores()
	else:
		# initialize new labirinth
		labirinth = Globals.LABIRINTH_SCENE.instantiate()

	$CanvasLayer/Menu/VBoxContainer/Play.disabled = true
	$CanvasLayer.show()

func _restart(view: Node) -> void:
	view.remove_models_child(player)
	view.restart(player)

func _show_scores() -> void:
	$CanvasLayer/Menu.hide()
	$CanvasLayer/Score.show()
	$CanvasLayer/Score/VBoxContainer/LastScore.text = str(_game_time)

	var score_entries: Dictionary = Globals.SCORES.get_scores()
	var score_keys: Array = score_entries.keys()
	score_keys.reverse()

	# show 10 best scores
	var rows: Array[Node] = $CanvasLayer/Score/VBoxContainer/VBoxContainer/Rows.get_children()
	var rows_size: int = rows.size()
	var row_index: int = 0
	while row_index < rows_size:
		if score_keys:
			var last_score: int = score_keys.pop_back()
			var last_names: Array = score_entries[last_score]
			for last_name: String in last_names:
				if row_index >= rows_size:
					break
				var row: HBoxContainer = rows[row_index]
				row.get_node("Name").text = last_name
				row.get_node("Time").text = str(last_score)
				row.show()
				row_index += 1
		else:
			rows[row_index].hide()
			row_index += 1

func _on_view_started() -> void:
	call_deferred("_start", labirinth)

func _on_view_restarted(view: Node) -> void:
	_restart(view)

func _on_view_changed(view: Node) -> void:
	Input.set_custom_mouse_cursor(null)
	_set_transition(_change, view)

func _on_view_exited(_view: Node) -> void:
	Input.set_custom_mouse_cursor(null)
	view_exited.emit(self)

func _on_back_pressed() -> void:
	Input.set_custom_mouse_cursor(null)
	view_exited.emit(self)

func _on_shoot_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.set_shoot_count(Globals.SHOOT_COUNT_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = false
	else:
		player.set_shoot_count(-Globals.SHOOT_COUNT_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = true

	$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shoot.icon = Globals.UPGRADE_ICONS["shoot"][
		player.get_shoot_count()
	]

func _on_strike_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.set_strike_force_step(Globals.STRIKE_FORCE_STEP_DIFF)
		player.set_max_strike_force(Globals.MAX_STRIKE_FORCE_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = false
	else:
		player.set_strike_force_step(-Globals.STRIKE_FORCE_STEP_DIFF)
		player.set_max_strike_force(-Globals.MAX_STRIKE_FORCE_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = true

	$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Strike.icon = Globals.UPGRADE_ICONS["strike"][
		int(player.get_strike_force_step())
	]

func _on_shield_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.set_shield_count(Globals.SHIELD_COUNT_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = false
	else:
		player.set_shield_count(-Globals.SHIELD_COUNT_DIFF)
		$CanvasLayer/Menu/VBoxContainer/Play.disabled = true

	$CanvasLayer/Menu/VBoxContainer/HBoxContainer/Shield.icon = Globals.UPGRADE_ICONS["shield"][
		int(player.get_shield_count())
	]

func _on_name_edit_text_submitted(new_text: String) -> void:
	if !new_text:
		return

	Globals.SCORES.set_score(_game_time, new_text)
	# disable name edit
	$CanvasLayer/Score/VBoxContainer/NameEdit.focus_mode = Control.FOCUS_NONE
	# show score
	_show_scores()

func _on_name_edit_text_changed(new_text: String) -> void:
	var caret_column: int = $CanvasLayer/Score/VBoxContainer/NameEdit.caret_column
	$CanvasLayer/Score/VBoxContainer/NameEdit.text = new_text.to_upper()
	$CanvasLayer/Score/VBoxContainer/NameEdit.caret_column = caret_column
