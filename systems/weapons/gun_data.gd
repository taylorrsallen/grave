class_name GunData extends Resource

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum FireMode {
	FULL_AUTO,
	SEMI_AUTO,
	SINGLE,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export_category("Model")
@export var model: PackedScene

@export_category("UI")
@export var name: String
@export var reticle: Texture2D
@export var ammo_per_row: int

@export_category("Effects")
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

@export var heat_per_shot: float = 2.0
@export var max_heat: float = 100.0

@export var last_round_sound: SoundReferenceData

@export_category("Bullet")
@export var bullet_id: int
@export var bullets_per_shot: int = 1
@export var spread_degrees: float = 0.0

@export_category("Recoil")
@export var position_recoil_min: Vector3 = Vector3(-0.025, -0.05, 0.2)
@export var position_recoil_max: Vector3 = Vector3( 0.025,  0.05, 0.5)
@export var angular_recoil_min: Vector3 = Vector3(-0.025, -0.05, 0.2)
@export var angular_recoil_max: Vector3 = Vector3( 0.025,  0.05, 0.5)
@export var recoil_force: float = 15.0

@export_category("Firing")
@export var rounds_per_second: float = 0.07518797
@export var reload_time: float = 2.5
@export var capacity: int = 30

@export_category("Fire Mode")
@export var default_fire_mode: FireMode = FireMode.SINGLE
@export var fire_modes: Array[FireMode] = [FireMode.SINGLE]
@export var semi_auto_burst_size: int

@export_category("Animations")
@export var firing_animation: String
@export var reload_animation: String
@export var character_reload_animation: String
