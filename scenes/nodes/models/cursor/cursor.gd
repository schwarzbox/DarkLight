extends Sprite2D

func _ready() -> void:
	hide_strike_cursor()

func _process(_delta: float) -> void:
	position = get_global_mouse_position()

func show_mouse_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hide()

func hide_mouse_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	show()

func show_strike_cursor() -> void:
	$StrikeBar.show()

func hide_strike_cursor() -> void:
	$StrikeBar.hide()

func set_strike_bar_value(value: float) -> void:
	$StrikeBar.set_value(value)

func hide_all() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide_strike_cursor()
	hide()
