extends CanvasLayer

var _tween: Tween = null
var _view: Node = null
var _callable: Callable


func _ready() -> void:
	prints(name, "ready")

	$ColorRect.modulate = Color(0, 0, 0, 0)


func fade(
	callable: Callable,
	view: Node = null,
	fade_delay: float = 1.0,
) -> void:
	_callable = callable
	_view = view

	if _tween:
		_tween.kill()

	_tween = create_tween()
	(
		_tween
		. tween_property($ColorRect, "modulate:a", 1, fade_delay)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN_OUT)
	)
	_tween.tween_callback(_execute)
	(
		_tween
		. tween_property($ColorRect, "modulate:a", 0, fade_delay)
		. set_trans(Tween.TRANS_LINEAR)
		. set_ease(Tween.EASE_IN_OUT)
	)


func _execute() -> void:
	if _callable:
		if _view:
			_callable.call(_view)
		else:
			_callable.call()
