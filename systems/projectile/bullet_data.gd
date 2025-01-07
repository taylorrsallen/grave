class_name BulletData extends Resource

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export_category("Appearance")
@export var icon: Texture2D
@export var ammo_box_model: PackedScene

@export_category("Gameplay")
@export var lifetime: float = 2.0
@export var speed: float = 10.0
@export var generic_hit_sound_pool: SoundPoolData

@export var damage_data: DamageData
