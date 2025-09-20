extends View
# custom main icon
# size of exe?

# check itch.io req

# screenshots itch.io
# web build itch.io

# Start fullscreen?
# Remove Debug?

# Release
# remove godot splash
# remove godot icon from build

var _game_view: View = null
var _score_view: View = null

func _ready() -> void:
	prints(name, "ready")

	Debug.remove_window_debug_tag()

	# remove score for web
	if OS.has_feature("web"):
		$CanvasLayer/CenterContainer/VBoxContainer/VBoxContainer/Score.hide()

	# Set world color
	RenderingServer.set_default_clear_color(Globals.COLORS.DEFAULT_BLACK)
	# Set custom cursor
	var sprite_size: Vector2 = Globals.CURSOR_ARROW_ICON.get_size()
	Input.set_custom_mouse_cursor(
		Globals.CURSOR_ARROW_ICON, Input.CursorShape.CURSOR_ARROW, sprite_size / 2
	)
	Input.set_custom_mouse_cursor(
		Globals.CURSOR_POINTING_HAND_ICON, Input.CursorShape.CURSOR_POINTING_HAND, sprite_size / 2
	)

	_center_window_on_screen()

	_setup()

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
	_game_view.connect("view_changed", self._on_view_changed)
	_game_view.connect("view_exited", self._on_view_exited)

	_score_view = Globals.SCORE_SCENE.instantiate()
	_score_view.connect("view_exited", self._on_view_exited)

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

func _on_game_pressed() -> void:
	_set_transition(_start, _game_view)

func _on_score_pressed() -> void:
	_set_transition(_start, _score_view)

func _on_exit_pressed() -> void:
	_set_transition(get_tree().quit)
