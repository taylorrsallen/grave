class_name FaceTarget extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var turn_speed: float = 100.0

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func face_point(point: Vector3, delta: float) -> void:
	var l_point: Vector3 = to_local(point)
	l_point.y = 0.0
	var turn_direction: float = sign(l_point.x)
	var turn_amount: float = deg_to_rad(turn_speed * delta)
	var angle: float = Vector3.FORWARD.angle_to(l_point)
	
	if angle < turn_amount: turn_amount = angle
	rotate_object_local(Vector3.UP, -turn_amount * turn_direction)

func is_facing_point(point: Vector3) -> bool:
	var l_point = to_local(point)
	return l_point.z < 0 && abs(l_point.x) < 0.1
