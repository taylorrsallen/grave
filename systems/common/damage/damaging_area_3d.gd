class_name DamagingArea3D extends Area3D

signal dealt_damage(body: PhysicsBody3D)

@export var active: bool = true
@export var damage_on_impact: bool = true
@export var damage_data: DamageData
@export var source: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody3D) -> void:
	if active && body is DamageableArea3D:
		if damage_on_impact:
			if is_instance_valid(source):
				body.damage(damage_data, source)
			else:
				body.damage_sourceless(damage_data)
		dealt_damage.emit(body)
