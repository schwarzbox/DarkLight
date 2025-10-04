extends View

# add help menu with controls
# fix git pages
# windows linux version
# add dev log balance (light bullet, exit, hide from light, flock)

var _game_view: View = null
var _score_view: View = null

var _audio_tween: Tween

func _ready() -> void:
	prints(name, "ready")

	if OS.has_feature("web"):
		# remove score for web
		$CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/Score.hide()

	# play intro
	$AudioStreamPlayer.volume_db = $AudioStreamPlayer.volume_db - 10
	$AudioStreamPlayer.play()
	_on_main_audio_resumed()

	# set world color
	RenderingServer.set_default_clear_color(Globals.COLORS.DEFAULT_BLACK)
	# set custom cursor
	var sprite_size: Vector2 = Globals.CURSOR_ARROW_ICON.get_size()
	Input.set_custom_mouse_cursor(
		Globals.CURSOR_ARROW_ICON, Input.CursorShape.CURSOR_ARROW, sprite_size / 2
	)
	Input.set_custom_mouse_cursor(
		Globals.CURSOR_POINTING_HAND_ICON, Input.CursorShape.CURSOR_POINTING_HAND, sprite_size / 2
	)

	_center_window_on_screen()

	_setup()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_ABOUT:
		if OS.has_feature("web"):
			return
		_about.call_deferred()

func _about() -> void:
	var about_scene: Window = preload("res://scenes/nodes/views/about/about.tscn").instantiate()
	add_child(about_scene)
	about_scene.connect("close_requested", about_scene.queue_free)
	about_scene.move_to_center()
	about_scene.show()

func _center_window_on_screen() -> void:
	var window: Window = get_window()
	var window_id: int = window.get_window_id()
	var display_id: int  = DisplayServer.window_get_current_screen(window_id)

	var window_size: Vector2i = window.get_size_with_decorations()
	var display_size: Vector2i = DisplayServer.screen_get_size(display_id)
	var window_position: Vector2i = (display_size / 2) - (window_size /2)
	window.position = window_position

func _setup() -> void:
	_game_view = Globals.GAME_SCENE.instantiate()
	_game_view.connect("view_changed", _on_view_changed)
	_game_view.connect("view_exited", _on_view_exited)
	_game_view.connect("main_audio_paused", _on_main_audio_paused)
	_game_view.connect("main_audio_resumed", _on_main_audio_resumed)

	_score_view = Globals.SCORE_SCENE.instantiate()
	_score_view.connect("view_exited", _on_view_exited)

	$CanvasLayer.show()

func _start(view: View) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer.hide()

func _on_view_changed(view: View) -> void:
	view.queue_free()
	if OS.has_feature("web"):
		# remove score for web
		_set_transition(_setup)
	else:
		_set_transition(_start, _score_view)

func _on_view_exited(view: View) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_main_audio_paused() -> void:
	if _audio_tween:
		_audio_tween.kill()
	_audio_tween = create_tween()
	_audio_tween.tween_property(
		$AudioStreamPlayer,
		"volume_db",
		$AudioStreamPlayer.volume_db - 20,
		Globals.UI_DELAY
	)
	_audio_tween.tween_callback(func() -> void: $AudioStreamPlayer.stream_paused = true)

func _on_main_audio_resumed() -> void:
	$AudioStreamPlayer.stream_paused = false
	if _audio_tween:
		_audio_tween.kill()
	_audio_tween = create_tween()
	_audio_tween.tween_property(
		$AudioStreamPlayer,
		"volume_db",
		$AudioStreamPlayer.volume_db + 20,
		Globals.UI_DELAY
	)

func _on_game_pressed() -> void:
	_set_transition(_start, _game_view)

func _on_score_pressed() -> void:
	_set_transition(_start, _score_view)

func _on_exit_pressed() -> void:
	_set_transition(get_tree().quit)
