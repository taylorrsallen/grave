class_name RadarBlip extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@onready var blip: MeshInstance3D = $Blip

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func update_position(camera_rig: CameraRig, character: Character, other_character: Character) -> void:
		basis = Basis.IDENTITY
		
		var distance_to_other: float = character.global_position.distance_to(other_character.global_position)
		
		var direction_to_other: Vector3 = (character.global_position - other_character.global_position).normalized()
		direction_to_other.y = 0.0
		direction_to_other = direction_to_other.normalized()
		
		var camera_direction: Vector3 = camera_rig.get_camera_forward()
		camera_direction.y = 0.0
		camera_direction = camera_direction.normalized()
		
		rotate_z(camera_direction.signed_angle_to(direction_to_other, Vector3.UP) + deg_to_rad(180))
		blip.position.y = 0.0225 * distance_to_other
		return
