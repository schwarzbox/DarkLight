class_name Body

extends Node2D

signal destroyed
signal self_destroyed
signal hp_changed

@export var _hp: int = 1:
	get = get_hp,
	set = set_hp
@export var _min_hp: int = 0
@export var _max_hp: int = 1

var _destroyed: bool = false:
	get = is_destroyed


func hit(damage: int) -> void:
	if is_destroyed():
		return

	set_hp(_hp - damage)
	if _hp <= _min_hp:
		_destroyed = true
		destroyed.emit()

func self_destroy() -> void:
	if is_destroyed():
		return

	_destroyed = true
	self_destroyed.emit()


func get_hp() -> int:
	return _hp

func set_hp(value: int) -> void:
	_hp = value
	hp_changed.emit(value)

func is_damaged() -> bool:
	return _hp < _max_hp

func is_destroyed() -> bool:
	return _destroyed

func regenerate(hp: int = 1) -> void:
	if is_damaged():
		var value: int = clampi(_hp + hp, _min_hp, _max_hp)
		set_hp(value)

func hp_ratio() -> float:
	return float(_hp) / float(_max_hp)
