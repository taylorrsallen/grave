class_name BulletBase extends Area3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var data: BulletData

var lifetime_timer: float = 0.0

#@onready var trail_3d: Trail3D = $Trail3D
@export var previous_position: Vector3

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().get_multiplayer_authority())
	
	if !is_multiplayer_authority():
		collision_layer = 0
		collision_mask = 0

func _physics_process(delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - global_basis.z * data.speed, 5, [])
	query.hit_from_inside = true
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.has("collider"):
		var hit_point: Vector3 = result["position"]
		var hit_normal: Vector3 = result["normal"]
		var hit_collider: Node3D = result["collider"]
		
		global_position = hit_point
		if is_multiplayer_authority(): _hit(hit_point, hit_normal, hit_collider)
	else:
		global_position += -global_basis.z * data.speed #+ Vector3.UP * sin(lifetime_timer * 10.0) * 0.05
	
	previous_position = global_position
	
	if !is_multiplayer_authority(): return
	lifetime_timer += delta
	if lifetime_timer >= data.lifetime: queue_free()

func _hit(_point: Vector3, _normal: Vector3, collider: Node3D) -> void:
	if collider is DamageableArea3D:
		var damage_data: DamageData = DamageData.new()
		collider.damage(data.damage_data, null)
	
	if collider.has_method("get_matter_id"):
		var matter_id: int = collider.get_matter_id()
		var matter_data: MatterData = Util.MATTER_DATABASE.database[matter_id]
		if matter_data.ballistic_hit_sfx_pool:
			var hit_sound: SoundReferenceData = matter_data.ballistic_hit_sfx_pool.pool.pick_random()
			SoundManager.play_pitched_3d_sfx(hit_sound.id, hit_sound.type, global_position)
		VfxManager.spawn_vfx(matter_data.ballistic_hit_vfx_id, global_position, Basis.looking_at(global_position - previous_position))
	else:
		var sound: SoundReferenceData = data.generic_hit_sound_pool.pool.pick_random()
		SoundManager.play_pitched_3d_sfx(sound.id, sound.type, global_position)
		VfxManager.spawn_vfx(0, global_position, Basis.looking_at(global_position - previous_position))
	
	queue_free()
