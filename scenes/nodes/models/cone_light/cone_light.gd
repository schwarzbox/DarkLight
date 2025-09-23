extends Node2D


func _ready() -> void:
	var interval: float = randf() * 0.5
	var tween: Tween = create_tween().set_loops()

	tween.tween_property($PointLight2D, "scale:y", 1.6, 1.0)
	tween.tween_interval(0.1 + interval)
	tween.tween_property($PointLight2D, "scale:y", 1.0, 1.0)
