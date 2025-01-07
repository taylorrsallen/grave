class_name HUD3D extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# COMPOSITION
@onready var reticle: MeshInstance3D = $Reticle
@onready var radar: MeshInstance3D = $Radar
@onready var ammo_display: AmmoDisplay = $AmmoDisplay
@onready var health_display: AmmoDisplay = $HealthDisplay
@onready var shield_display: AmmoDisplay = $ShieldDisplay
@onready var interact_prompt: Label3D = $InteractPrompt

@onready var ammo_stock_counter: Label3D = $AmmoStockWidget/AmmoStockCounter
@onready var ammo_stock_icon: AmmoRowMesh = $AmmoStockWidget/Node3D/AmmoRowMesh

@onready var single_back: Label3D = $FireModeDisplay/SingleBack
@onready var single_front: Label3D = $FireModeDisplay/SingleBack/SingleFront
@onready var semi_auto_back: Label3D = $FireModeDisplay/SemiAutoBack
@onready var semi_auto_front: Label3D = $FireModeDisplay/SemiAutoBack/SemiAutoFront
@onready var full_auto_back: Label3D = $FireModeDisplay/FullAutoBack
@onready var full_auto_front: Label3D = $FireModeDisplay/FullAutoBack/FullAutoFront


# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func update_reticle(camera_rig: CameraRig, character: Character) -> void:
	if reticle.get_surface_override_material(0).albedo_texture != character.gun_base.data.reticle:
		reticle.get_surface_override_material(0).albedo_texture = character.gun_base.data.reticle
	
	var recoil_distance_mod: float = character.gun_barrel_angular_recoil_modifier.dot(Vector3.ZERO) * 8.0 + character.gun_barrel_position_recoil_modifier.length() * 7.0
	
	var reticle_target: Vector3 = character.gun_base.global_position - character.gun_base.global_basis.z * 100.0
	var space_state: PhysicsDirectSpaceState3D = character.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(character.gun_base.global_position, character.gun_base.global_position - character.gun_base.global_basis.z * 100.0, 3, [character.get_rid()])
	var result: Dictionary = space_state.intersect_ray(query)
	if !result.is_empty(): reticle_target = result["position"]
	var reticle_direction_from_camera: Vector3 = (reticle_target - camera_rig.camera_3d.global_position).normalized()
	
	reticle.global_position = camera_rig.camera_3d.global_position + reticle_direction_from_camera * (10.0 - recoil_distance_mod - character.gun_base.data.spread_degrees)
	reticle.global_basis = character.gun_base.global_basis
	#print(character.gun_barrel_angular_recoil_modifier)
	#print(character.gun_barrel_angular_recoil_modifier.dot(Vector3.ZERO))
	#print(reticle.global_position.distance_to(camera_rig.camera_3d.global_position))

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func set_ammo_stock_count(ammo: int) -> void:
	ammo_stock_counter.text = "x " + str(ammo)

func set_ammo_stock_icon(icon: Texture2D) -> void:
	ammo_stock_icon.get_surface_override_material(0).albedo_texture = icon
	ammo_stock_icon.mesh.size.x = icon.get_size().x * 0.01
	ammo_stock_icon.mesh.size.y = icon.get_size().y * 0.01

func set_fire_mode_displayed(fire_mode: GunData.FireMode) -> void:
	match fire_mode:
		GunData.FireMode.SEMI_AUTO:
			single_front.hide()
			semi_auto_front.show()
			full_auto_front.hide()
		GunData.FireMode.FULL_AUTO:
			single_front.hide()
			semi_auto_front.hide()
			full_auto_front.show()
		_:
			single_front.show()
			semi_auto_front.hide()
			full_auto_front.hide()

func set_available_fire_modes_displayed(fire_modes: Array[GunData.FireMode]) -> void:
	single_front.hide()
	single_back.hide()
	semi_auto_front.hide()
	semi_auto_back.hide()
	full_auto_front.hide()
	full_auto_back.hide()
	for fire_mode in fire_modes:
		match fire_mode:
			GunData.FireMode.SEMI_AUTO: semi_auto_back.show()
			GunData.FireMode.FULL_AUTO: full_auto_back.show()
			_: single_back.show()
