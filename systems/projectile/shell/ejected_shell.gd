class_name EjectedShell extends RigidBody3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	apply_impulse((-get_parent().global_basis.z * 0.4 + Vector3.UP * 0.7 + get_parent().global_basis.x * 0.3) * randf_range(1.0, 3.0))
	constant_torque = Vector3(randf_range(-30.0, 40.0), randf_range(-10.0, 20.0), randf_range(60.0, 100.0))
