class_name GunBase extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
var GUN_DATABASE: GunDatabase = load("res://resources/weapons/guns/gun_database.res")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var data_id: int: set = _set_data_id
@export var data: GunData: set = _set_data
@export var model: GunModel

@export var reloading: bool = false
@export var amount_to_reload: int

@export var fire_timer: float = 0.0
@export var reload_timer: float = 0.0
@export var rounds: int = 0

@export var heat: float

@export var fire_mode_index: int

@export var lingering_smoke: GPUParticles3D

@onready var smoke_trail: Trail3D = $SmokeTrail
@export var smoke_width_range: Vector2 = Vector2(0.01, 0.03)
@export var recently_fired: float
@export var smoke_time: float = 0.5
@export var smoke_timer: float

var semi_auto_rounds_fired: int
var semi_auto_firing: bool

var equipped_to_character: Character

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_data_id(_data_id: int) -> void:
	data_id = _data_id
	if data_id == 0:
		data = null
	else:
		data = GUN_DATABASE.database[data_id - 1]

func _set_data(_data: GunData) -> void:
	data = _data
	
	if is_instance_valid(model): model.queue_free()
	if !data: return
	model = data.model.instantiate()
	add_child(model)
	rounds = data.capacity
	refresh_fire_mode()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	if data: data = data

func _physics_process(delta: float) -> void:
	if !data: return
	if !multiplayer.multiplayer_peer: return
	if !is_instance_valid(model): return
	
	if is_multiplayer_authority():
		fire_timer = clampf(fire_timer + delta, 0.0, data.rounds_per_second)
	
	if reloading:
		model.magazine_model.hide()
		if is_multiplayer_authority():
			reload_timer += delta
			if reload_timer >= data.reload_time:
				reload()
	else:
		model.magazine_model.show()
		
		if semi_auto_firing:
			if fire_timer >= data.rounds_per_second:
				if rounds > 0:
					_fire(0, equipped_to_character)
					semi_auto_rounds_fired += 1
					if semi_auto_rounds_fired >= data.semi_auto_burst_size:
						semi_auto_rounds_fired = 0
						semi_auto_firing = false
				else:
					semi_auto_firing = false
					semi_auto_rounds_fired = 0
					_dry_fire()
	
	recently_fired = clampf(recently_fired - delta, 0.0, 0.3)
	if smoke_timer < smoke_time && recently_fired == 0.0:
		smoke_timer = clampf(smoke_timer + delta, 0.0, smoke_time)
		smoke_trail.global_position = model.muzzle.global_position
		smoke_trail._from_width = clampf(smoke_trail._from_width + randf_range(-0.025, 0.025) * sin(smoke_timer), smoke_width_range.x, smoke_width_range.y)
		smoke_trail._trail_enabled = true
	else:
		smoke_trail._trail_enabled = false
	
	if is_multiplayer_authority(): heat = move_toward(heat, 0.0, delta * 5.0)
	var barrel_color: Color = model.barrel_base_color.lerp(model.barrel_overheat_color, heat / data.max_heat)
	model.barrel_model.get_surface_override_material(0).albedo_color = barrel_color

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func try_fire_held_press(player_id: int, character: Character, _delta: float) -> void:
	if semi_auto_firing: return
	if !data: return
	if !data.fire_modes.has(GunData.FireMode.FULL_AUTO) || data.fire_modes[fire_mode_index] != GunData.FireMode.FULL_AUTO: return
	
	if !reloading:
		if rounds > 0:
			if fire_timer >= data.rounds_per_second: _fire(player_id, character)

func try_fire_single_press(player_id: int, character: Character, _delta: float) -> void:
	if semi_auto_firing: return
	if !data: return
	
	if !reloading && rounds == 0:
		_dry_fire()
		return
	
	if get_fire_mode() == GunData.FireMode.SEMI_AUTO:
		semi_auto_firing = true
		return
	if get_fire_mode() == GunData.FireMode.FULL_AUTO: return
	if !reloading && rounds > 0: _fire(player_id, character)

func _fire(player_id: int, character: Character) -> void:
	fire_timer = 0.0
	rounds -= 1
	heat += data.heat_per_shot
	recently_fired = 0.1
	smoke_timer = 0.0
	
	if rounds == 0: last_round_effect()
	
	for i in data.bullets_per_shot:
		SpawnManager.spawn_client_owned_bullet(player_id, data.bullet_id, model.muzzle.global_position, model.muzzle.global_basis.rotated(Vector3((randf() - 0.5) * 2.0, (randf() - 0.5) * 2.0, (randf() - 0.5) * 2.0).normalized(), deg_to_rad(data.spread_degrees)))
	
	character.gun_barrel_position_recoil_modifier += Vector3(randf_range(data.position_recoil_min.x, data.position_recoil_max.x), randf_range(data.position_recoil_min.y, data.position_recoil_max.y), randf_range(data.position_recoil_min.z, data.position_recoil_max.z))
	character.gun_barrel_angular_recoil_modifier += Vector3(randf_range(data.angular_recoil_min.x, data.angular_recoil_max.x), randf_range(data.angular_recoil_min.y, data.angular_recoil_max.y), randf_range(data.angular_recoil_min.z, data.angular_recoil_max.z))
	character.apply_force(model.muzzle.global_basis.z * data.recoil_force)
	VfxManager.spawn_vfx(1, model.muzzle.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(3, model.ejection_port.global_position, model.ejection_port.global_basis)
	VfxManager.spawn_vfx(4, model.ejection_port.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(2, model.muzzle.global_position, model.muzzle.global_basis)
	VfxManager.spawn_vfx(5, model.muzzle.global_position, model.muzzle.global_basis)
	var sound: SoundReferenceData = data.fire_sound_pool.pool.pick_random()
	SoundManager.play_pitched_3d_sfx(sound.id, sound.type, model.muzzle.global_position)
	character.snap_gun_aim()

func _dry_fire() -> void:
	fire_timer = 0.0
	SoundManager.play_pitched_3d_sfx(2, SoundDatabase.SoundType.SFX_FOLEY, model.magazine_grab.global_position)

func last_round_effect() -> void:
	if data.last_round_sound:
		SoundManager.play_pitched_3d_sfx(data.last_round_sound.id, data.last_round_sound.type, model.magazine_grab.global_position, 0.9, 1.1, 70.0)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func try_reload() -> void:
	if !data: return
	if rounds == data.capacity || !is_instance_valid(model) || reloading: return
	if equipped_to_character.inventory.ammo_stock[data.bullet_id] == 0: return
	
	var ammo_desired: int = data.capacity - rounds
	
	SoundManager.play_pitched_3d_sfx(0, SoundDatabase.SoundType.SFX_FOLEY, model.magazine_grab.global_position)
	reloading = true
	amount_to_reload = min(ammo_desired, equipped_to_character.inventory.ammo_stock[data.bullet_id])

func reload() -> void:
	reload_timer = 0.0
	SoundManager.play_pitched_3d_sfx(1, SoundDatabase.SoundType.SFX_FOLEY, model.muzzle.global_position)
	reloading = false
	rounds += amount_to_reload
	equipped_to_character.inventory.ammo_stock[data.bullet_id] -= amount_to_reload
	amount_to_reload = 0

func interrupt_reload() -> void:
	reload_timer = 0.0
	reloading = false


func cycle_fire_mode() -> void:
	fire_mode_index = (fire_mode_index + 1) % data.fire_modes.size()
	if data.fire_modes.size() > 1:
		SoundManager.play_pitched_3d_sfx(4, SoundDatabase.SoundType.SFX_FOLEY, model.magazine_grab.global_position)

func refresh_fire_mode() -> void:
	fire_mode_index = fire_mode_index % data.fire_modes.size()

func get_fire_mode() -> GunData.FireMode:
	return data.fire_modes[fire_mode_index]
