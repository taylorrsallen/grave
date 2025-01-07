extends Resource
class_name DamageData

enum DamageType {
	SHARP,
	BLUNT,
	ELEMENTAL,
}

enum DamageMaterial {
	METAL,
	FIRE,
}

@export var damage_type: DamageType
@export var damage_material: DamageMaterial
@export var damage_strength: float
