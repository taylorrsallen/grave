class_name Lifetime extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var lifetime: float = 5.0
var timer: float = 0.0

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime: get_parent().queue_free()
