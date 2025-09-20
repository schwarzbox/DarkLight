extends Node2D

func _ready() -> void:
	var interval: float = randf() * 0.5
	var tween: Tween = create_tween().set_loops()

	tween.tween_property($PointLight2D, "texture_scale", 0.8, 1)
	tween.tween_interval(0.1 + interval)
	tween.tween_property($PointLight2D, "texture_scale", 1.0, 1)

func get_light_color() -> Color:
	return $PointLight2D.color

func set_light_color(value: Color) -> void:
	$PointLight2D.color = value
