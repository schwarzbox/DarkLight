extends Sprite2D


func _process(_delta: float) -> void:
	position = get_global_mouse_position()

func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	show()

func hide_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hide()

func set_strike_bar_value(value: float) -> void:
	$StrikeBar.set_value(value)
