class_name GunBase extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var data: GunData: set = _set_data
@export var model: GunModel

@export var reloading: bool = false
@export var fire_timer: float = 0.0
@export var reload_timer: float = 0.0
@export var rounds: int = 0

@export var fire_mode: GunData.FireMode

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_data(_data: GunData) -> void:
	data = _data
	
	model = data.model.instantiate()
	add_child(model)
	rounds = data.capacity

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	if data: data = data

func _physics_process(delta: float) -> void:
	if !data: return
	
	if reloading:
		model.magazine_model.hide()
		reload_timer += delta
		if reload_timer >= data.reload_time:
			reload_timer = 0.0
			SoundManager.play_pitched_3d_sfx(1, SoundDatabase.SoundType.SFX_FOLEY, model.muzzle.global_position)
			reloading = false
			rounds = data.capacity
	else:
		model.magazine_model.show()

func try_fire(player_id: int, character: Character, delta: float) -> void:
	if !data: return
	
	fire_timer = clampf(fire_timer + delta, 0.0, data.rounds_per_second)
	if !reloading:
		if rounds > 0:
			if fire_timer >= data.rounds_per_second: _fire(player_id, character)
		else:
			SoundManager.play_pitched_3d_sfx(0, SoundDatabase.SoundType.SFX_FOLEY, model.magazine_grab.global_position)
			reloading = true

func _fire(player_id: int, character: Character) -> void:
	fire_timer = 0.0
	rounds -= 1
	character.gun_barrel_position_recoil_modifier += Vector3(randf_range(data.position_recoil_min.x, data.position_recoil_max.x), randf_range(data.position_recoil_min.y, data.position_recoil_max.y), randf_range(data.position_recoil_min.z, data.position_recoil_max.z))
	character.gun_barrel_angular_recoil_modifier += Vector3(randf_range(data.angular_recoil_min.x, data.angular_recoil_max.x), randf_range(data.angular_recoil_min.y, data.angular_recoil_max.y), randf_range(data.angular_recoil_min.z, data.angular_recoil_max.z))
	character.apply_force(model.muzzle.global_basis.z * data.recoil_force)
	SpawnManager.spawn_client_owned_object(player_id, 0, 0, model.muzzle.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(1, model.muzzle.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(3, model.ejection_port.global_position, model.ejection_port.global_basis)
	VfxManager.spawn_vfx(4, model.ejection_port.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(2, model.muzzle.global_position, model.muzzle.global_basis)
	SoundManager.play_pitched_3d_sfx(2, SoundDatabase.SoundType.SFX_EXPLOSION, model.muzzle.global_position)
	character.snap_gun_aim()
