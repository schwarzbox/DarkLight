class_name View

extends Node

@warning_ignore("unused_signal")
signal view_restarted
@warning_ignore("unused_signal")
signal view_changed
@warning_ignore("unused_signal")
signal view_exited


func is_world_has_children() -> bool:
	return $World.get_child_count() > 0


func add_world_child(child: Node) -> void:
	$World.add_child(child)


func remove_world_child(child: Node) -> void:
	$World.remove_child(child)


func _set_transition(method: Callable, view: Node = null) -> void:
	Transition.fade(method, view)
