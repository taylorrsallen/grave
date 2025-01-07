class_name BulletBase extends Area3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
var lifetime: float = 2.0
var lifetime_timer: float = 0.0

var speed: float = 10.0

#@onready var trail_3d: Trail3D = $Trail3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().get_multiplayer_authority())
	$Label3D.text = str(get_multiplayer_authority())
	
	if !is_multiplayer_authority():
		collision_layer = 0
		collision_mask = 0

#func _exit_tree() -> void:
	#var trail: GPUTrail3D = $GPUTrail3D
	#var lifetime: Lifetime = Lifetime.new()
	#lifetime.lifetime = 3.0
	#trail.add_child(lifetime)
	#trail.reparent(get_tree().root)
	#trail.global_position = global_position

func _ready() -> void:
	#trail_3d.reparent(get_tree().root)
	
	ray_cast_3d.target_position.z = -speed

func _physics_process(delta: float) -> void:
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		var hit_point: Vector3 = ray_cast_3d.get_collision_point()
		var hit_normal: Vector3 = ray_cast_3d.get_collision_normal()
		var hit_collider: Node3D = ray_cast_3d.get_collider()
		
		global_position = hit_point
		if is_multiplayer_authority(): _on_body_entered(null)
	else:
		global_position += -global_basis.z * speed #+ Vector3.UP * sin(lifetime_timer * 10.0) * 0.05
	
	DebugDraw3D.draw_line(global_position, global_position - global_basis.z * 50.0, Color.GREEN, delta)
	
	#trail_3d.global_position = global_position# + global_basis.z * speed
	
	if !is_multiplayer_authority(): return
	lifetime_timer += delta
	if lifetime_timer >= lifetime: queue_free()

func _on_body_entered(body: Node3D) -> void:
	SoundManager.play_pitched_3d_sfx(1, SoundDatabase.SoundType.SFX_EXPLOSION, global_position)
	VfxManager.spawn_vfx(0, global_position, global_basis)
	queue_free()
