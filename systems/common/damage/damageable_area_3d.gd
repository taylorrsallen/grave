class_name DamageableArea3D extends StaticBody3D

signal damaged(damage_data: DamageData, area_id: int, source: Node)

@export var id: int
@export var source: Node3D

func damage(damage_data: DamageData, _source: Node) -> void:
	damaged.emit(damage_data, id, _source)

func damage_sourceless(damage_data: DamageData) -> void:
	damaged.emit(damage_data, id, null)

func get_matter_id() -> int:
	return source.get_matter_id_for_damageable_area_3d(id)
