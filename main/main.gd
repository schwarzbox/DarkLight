extends View
# web build itch.io
# screenshots
# update README like Love
# strike without damage?

# Release
# ?
# high scores in main menu with logo? (separate view)

var _game_view: View = null

func _ready() -> void:
	prints(name, "ready")

	# Set world color
	RenderingServer.set_default_clear_color(Color.BLACK)

	_center_window_on_screen()

	for node: Control in [
		$CanvasLayer/CenterContainer/VBoxContainer/VBoxContainer/Game,
		$CanvasLayer/CenterContainer/VBoxContainer/VBoxContainer/Exit,
	]:
		node.add_theme_font_size_override(
			"font_size", Globals.FONTS.MEDIUM_FONT_SIZE
		)

	randomize()

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
	_game_view.connect("view_exited", self._on_view_exited)

	$CanvasLayer.show()

func _start(view: View) -> void:
	add_world_child(view)

	if is_world_has_children():
		$CanvasLayer.hide()

func _on_view_exited(view: View) -> void:
	view.queue_free()
	_set_transition(_setup)

func _on_game_pressed() -> void:
	_set_transition(_start, _game_view)

func _on_exit_pressed() -> void:
	_set_transition(func() -> void: get_tree().quit(), self)
