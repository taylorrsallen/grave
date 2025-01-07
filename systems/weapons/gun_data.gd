class_name GunData extends Resource

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum FireMode {
	FULL_AUTO,
	SEMI_AUTO,
	SINGLE,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# MODEL
@export var model: PackedScene

# EFFECTS
@export var fire_sound_pool: SoundPoolData
@export var shell_ejection_sound_pool: SoundPoolData

@export var muzzle_flash_pool: int
## The immediate smoke discharge upon firing
@export var muzzle_smoke: int
@export var muzzle_lingering_smoke: int

## The shell that flies out of the ejection port
@export var shell_ejection_pool: int
## The smoke effect when a shell flies out of the ejection port
@export var shell_ejection_smoke_pool: int

# FIRING
@export var bullet_data: int

@export var position_recoil_min: Vector3 = Vector3(-0.025, -0.05, 0.2)
@export var position_recoil_max: Vector3 = Vector3( 0.025,  0.05, 0.5)
@export var angular_recoil_min: Vector3 = Vector3(-0.025, -0.05, 0.2)
@export var angular_recoil_max: Vector3 = Vector3( 0.025,  0.05, 0.5)
@export var recoil_force: float = 15.0

@export var rounds_per_second: float = 0.07518797
@export var reload_time: float = 2.5
@export var capacity: int = 30

@export var default_fire_mode: FireMode = FireMode.SINGLE
@export var fire_modes: Array[FireMode] = [FireMode.SINGLE]

# ANIMATIONS
@export var firing_animation: String
@export var reload_animation: String
@export var character_reload_animation: String
