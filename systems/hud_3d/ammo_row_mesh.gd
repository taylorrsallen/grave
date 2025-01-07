@tool
class_name AmmoRowMesh extends MeshInstance3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var ammo: int: set = _set_ammo
@export var size_per_ammo: float = 0.5

func _set_ammo(_ammo: int) -> void:
	ammo = clampi(_ammo, 0, 100)
	if !get_surface_override_material(0).albedo_texture: return
	mesh.size.y = get_surface_override_material(0).albedo_texture.get_size().y * 0.01
	mesh.size.x = ammo * get_surface_override_material(0).albedo_texture.get_size().x * 0.01
	get_surface_override_material(0).uv1_scale.x = ammo
	position.x = -mesh.size.x * 0.5
