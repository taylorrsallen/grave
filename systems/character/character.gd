class_name Character extends RigidBody3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
signal spawned_on_peer(peer_id: int, character: Character)
signal jumped()
signal landed(force: float)
signal killed()

signal water_entered()
signal water_exited()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum CharacterFlag {
	GROUNDED,
	WALK,
	SPRINT,
	CROUCH,
	TUMBLING,
	NOCLIP,
	WATER,
	UNDERWATER,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## COMPOSITION
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var nav_collider: CollisionShape3D = $NavCollider
@onready var spring_ray: RayCast3D = $NavCollider/SpringRay
@onready var body_container: Node3D = $BodyContainer
#@onready var body: CharacterBody = $BodyContainer/Body

@onready var gun_barrel_ik_target: Marker3D = $GunBarrelIKTarget
@onready var l_hand_ik_target: Marker3D = $LHandIKTarget
@onready var r_hand_ik_target: Marker3D = $RHandIKTarget

@onready var gun_base: GunBase = $GunBarrelIKTarget/GunBase


## FLAGS
@export var flags: int

## MOVEMENT
@export var max_ground_angle: float = 0.75

@export var ride_height: float = 1.22
@export var ride_spring_strength: float = 220.0
@export var ride_spring_damper: float = 20.0
@export var upright_rotation: Quaternion = Quaternion.IDENTITY
@export var upright_spring_strength: float = 25.0
@export var upright_spring_damper: float = 3.0

var look_basis: Basis
var look_direction: Vector3
var look_scalar: float

var move_input: Vector3
var world_move_input: Vector3
var desired_facing: Vector3
var move_direction: Vector3
@export var move_direction_lerp_speed: float = 10.0
@export var move_accel_lerp_speed: float = 3.0

@export var crouch_speed: float = 4.5
@export var walk_speed: float = 3.0
@export var jog_speed: float = 5.0
@export var sprint_speed: float = 8.0
var current_speed: float = walk_speed

@export var jump_velocity: float = 4.5

var last_velocity: Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

## VEHICLE
@export var vehicle: Node3D

## AIMING
@export var breath: Vector3
@export var breath_timer: float
@export var gun_barrel_look_direction: Vector3
@export var gun_barrel_look_target: Vector3
@export var gun_barrel_position_target: Vector3
@export var gun_barrel_position_recoil_modifier: Vector3
@export var gun_barrel_angular_recoil_modifier: Vector3

@export var l_hand_ik_target_target: Vector3
@export var r_hand_ik_target_target: Vector3

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func is_flag_on(flag: CharacterFlag) -> bool: return Util.is_flag_on(flags, flag)
func set_flag_on(flag: CharacterFlag) -> void: flags = Util.set_flag_on(flags, flag)
func set_flag_off(flag: CharacterFlag) -> void: flags = Util.set_flag_off(flags, flag)
func set_flag(flag: CharacterFlag, active: bool) -> void: flags = Util.set_flag(flags, flag, active)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _physics_process(delta: float) -> void:
	if !vehicle:
		_update_movement(delta)
		_update_aim(delta)
	else:
		pass # Send inputs to vehicle, just like how Controller sends input to Character

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func face_direction(direction: Vector3, delta: float) -> void:
	Util.rotate_yaw_to_target(delta * move_direction_lerp_speed, body_container, body_container.global_position + direction)
	#body_center_pivot.basis = Basis.IDENTITY
	nav_collider.basis = Basis.IDENTITY

func look_in_direction(look_basiss: Basis, _delta: float) -> void:
	$BodyContainer/MeshInstance3D.global_basis = look_basiss

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _update_aim(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	# Update breath vector, used to add a little bit of natural movement to the aim so that it isn't robotically perfect
	breath_timer += delta
	breath = Vector3(sin(breath_timer * 0.1), sin(breath_timer * 0.3), sin(breath_timer * 0.1)) * 0.3
	
	# Barrel position recoil
	var raw_position_recoil: Vector3 = gun_barrel_position_recoil_modifier * 0.1 + breath * 0.1
	var position_recoil: Vector3 = (raw_position_recoil.x * gun_barrel_ik_target.global_basis.x + raw_position_recoil.y * gun_barrel_ik_target.global_basis.y + raw_position_recoil.z * gun_barrel_ik_target.global_basis.z)
	
	gun_barrel_ik_target.global_position = gun_barrel_ik_target.global_position.move_toward(gun_barrel_position_target + position_recoil, delta * clampf(gun_barrel_ik_target.global_position.distance_to(gun_barrel_position_target) * 55.0, 2.0, 99.0))
	
	# Barrel look direction recoil
	var look_recoil: Vector3 = (gun_barrel_angular_recoil_modifier.x * gun_barrel_ik_target.global_basis.x + gun_barrel_angular_recoil_modifier.y * gun_barrel_ik_target.global_basis.y)
	
	var gun_barrel_look_direction_target: Vector3 = (gun_barrel_look_target - gun_barrel_ik_target.global_position).normalized()
	gun_barrel_look_direction = gun_barrel_look_direction.move_toward(gun_barrel_look_direction_target + look_recoil, delta * clampf(gun_barrel_look_direction.distance_to(gun_barrel_look_direction_target) * 15.0, 1.05, 99.0))
	gun_barrel_ik_target.look_at(gun_barrel_ik_target.global_position + gun_barrel_look_direction)
	
	# Barrel steadying
	# TODO: Affected by gun weight & arm strength
	gun_barrel_position_recoil_modifier = gun_barrel_position_recoil_modifier.move_toward(Vector3.ZERO, delta * clampf(gun_barrel_position_recoil_modifier.distance_to(Vector3.ZERO) * 15.0, 1.05, 99.0))
	gun_barrel_angular_recoil_modifier = gun_barrel_angular_recoil_modifier.move_toward(Vector3.ZERO, delta * clampf(gun_barrel_angular_recoil_modifier.distance_to(Vector3.ZERO) * 15.0, 1.05, 99.0))
	
	if is_instance_valid(gun_base.model):
		if is_instance_valid(gun_base.model.l_hand_grip): l_hand_ik_target.global_position = gun_base.model.l_hand_grip.global_position
		if is_instance_valid(gun_base.model.r_hand_grip): r_hand_ik_target.global_position = gun_base.model.r_hand_grip.global_position

func snap_gun_aim() -> void:
	var look_recoil: Vector3 = (gun_barrel_angular_recoil_modifier.x * gun_barrel_ik_target.global_basis.x + gun_barrel_angular_recoil_modifier.y * gun_barrel_ik_target.global_basis.y)
	
	var gun_barrel_look_direction_target: Vector3 = (gun_barrel_look_target - gun_barrel_ik_target.global_position).normalized()
	gun_barrel_look_direction = gun_barrel_look_direction_target + look_recoil
	gun_barrel_ik_target.look_at(gun_barrel_ik_target.global_position + gun_barrel_look_direction)

func _update_movement(delta: float) -> void:
	if is_flag_on(CharacterFlag.CROUCH):
		current_speed = crouch_speed
	elif is_flag_on(CharacterFlag.WALK):
		current_speed = walk_speed
	elif is_flag_on(CharacterFlag.SPRINT):
		current_speed = sprint_speed
	else:
		current_speed = jog_speed
	
	if is_flag_on(CharacterFlag.NOCLIP):
		_update_movement_noclip(delta)
	elif is_flag_on(CharacterFlag.UNDERWATER):
		_update_movement_underwater(delta)
	else:
		_update_movement_grounded(delta)

func _update_movement_noclip(delta: float) -> void:
	if is_flag_on(CharacterFlag.CROUCH): world_move_input.y = -1.0
	move_direction = lerp(move_direction, world_move_input.normalized(), delta * move_direction_lerp_speed)
	if world_move_input == Vector3.ZERO: set_flag_off(CharacterFlag.SPRINT)
	
	var noclip_speed: float = sprint_speed if !is_flag_on(CharacterFlag.SPRINT) else sprint_speed * 16.0
	global_position += move_direction * noclip_speed * delta

func _update_movement_underwater(delta: float) -> void:
	## Look left/right = roll
	## Look up/down = pitch
	## Move left/right = yaw
	## Move up/down = velocity
	
	move_direction = lerp(move_direction, -look_direction * move_input.z, delta * move_direction_lerp_speed)
	
	if move_direction != Vector3.ZERO:
		linear_velocity.x = move_toward(linear_velocity.x, move_direction.x * current_speed, current_speed)
		linear_velocity.y = move_toward(linear_velocity.y, move_direction.y * current_speed, current_speed)
		linear_velocity.z = move_toward(linear_velocity.z, move_direction.z * current_speed, current_speed)
		#body.set_walking(true)
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0.0, current_speed)
		linear_velocity.y = move_toward(linear_velocity.y, 0.0, current_speed)
		linear_velocity.z = move_toward(linear_velocity.z, 0.0, current_speed)
		#body.set_walking(false)
	
	if world_move_input == Vector3.ZERO:
		set_flag_off(CharacterFlag.SPRINT)
		#body.set_walking(false)
	
	#body_center_pivot.basis = body_center_pivot.basis.orthonormalized().slerp(look_basis.orthonormalized(), 0.1).orthonormalized()
	#nav_collider.basis = body_center_pivot.basis
	#body_container.basis = Basis.IDENTITY
	
	last_velocity = linear_velocity
	#move_and_slide()

func _update_movement_grounded(delta: float) -> void:
	#_update_upright_rotation()
	#_update_upright_force()
	_update_ride_force()
	
	if is_flag_on(CharacterFlag.GROUNDED) && last_velocity.y < -1.0:
		landed.emit(-last_velocity.y)
	
	if !is_flag_on(CharacterFlag.GROUNDED):
		linear_velocity.y -= gravity * delta
	elif world_move_input.y > 0.0:
		linear_velocity.y += jump_velocity
		jumped.emit()
	
	if is_flag_on(CharacterFlag.GROUNDED):
		move_direction = lerp(move_direction, Vector3(world_move_input.x, 0.0, world_move_input.z).normalized(), delta * move_direction_lerp_speed)
		
		if move_direction != Vector3.ZERO:
			linear_velocity.x = move_toward(linear_velocity.x, move_direction.x * current_speed, current_speed * delta * move_accel_lerp_speed)
			linear_velocity.z = move_toward(linear_velocity.z, move_direction.z * current_speed, current_speed * delta * move_accel_lerp_speed)
		else:
			linear_velocity.x = move_toward(linear_velocity.x, 0.0, current_speed * delta * move_accel_lerp_speed)
			linear_velocity.z = move_toward(linear_velocity.z, 0.0, current_speed * delta * move_accel_lerp_speed)
	
	if world_move_input == Vector3.ZERO: set_flag_off(CharacterFlag.SPRINT)
	
	last_velocity = linear_velocity

func _update_upright_rotation() -> void:
	var look_transform: Transform3D = Transform3D.IDENTITY

	if move_input == Vector3.ZERO:
		var forward = -basis.z + global_position
		forward.y = 0.0
		forward = forward.normalized()
		look_transform = look_transform.looking_at(forward)
	elif move_input.x == 0.0 && move_input.z == 0.0:
		return
	else:
		var input_normalized = move_direction
		input_normalized.y = 0.0
		input_normalized = input_normalized.normalized()
		
		var look_at_vec: Vector3 = Vector3(input_normalized.x, -0.1 * input_normalized.length(), input_normalized.z)
		look_transform = look_transform.looking_at(look_at_vec)
	
	upright_rotation = look_transform.basis.get_rotation_quaternion()
	#rotation = look_transform.basis.get_euler()

func _update_upright_force() -> void:
	var current_rotation = Quaternion.from_euler(rotation)
	var to_goal: Quaternion = Util.shortest_rotation(upright_rotation, current_rotation)
	
	var axis: Vector3 = to_goal.get_axis()
	var angle: float = to_goal.get_angle()
	axis = axis.normalized()
	
	constant_torque = (axis * (angle * upright_spring_strength)) - (angular_velocity * upright_spring_damper)

func _update_ride_force() -> void:
	if spring_ray.is_colliding():
		var hit_point: Vector3 = spring_ray.get_collision_point()
		var hit_toi: float = (hit_point - spring_ray.global_position).length()
		var other_collider: Node3D = spring_ray.get_collider()
		
		if hit_toi <= ride_height + ride_height * 0.1:
			# Close enough to be grounded
			if spring_ray.get_collision_normal().y < max_ground_angle:
				set_flag_off(CharacterFlag.GROUNDED)
			else:
				set_flag_on(CharacterFlag.GROUNDED)
		else:
			set_flag_off(CharacterFlag.GROUNDED)
		
		if !is_flag_on(CharacterFlag.GROUNDED):
			constant_force = Vector3.ZERO
			return
		
		var other_linvel: Vector3 = other_collider.linear_velocity if other_collider is RigidBody3D else Vector3.ZERO
		var ray_direction_velocity: float = Vector3.DOWN.dot(linear_velocity)
		var other_direction_velocity: float = Vector3.DOWN.dot(other_linvel)
		var relative_velocity: float = ray_direction_velocity - other_direction_velocity
		
		var x: float = hit_toi - ride_height
		var spring_force: float = (x * ride_spring_strength) - (relative_velocity * ride_spring_damper)
		
		constant_force = Vector3.DOWN * spring_force
		
		if other_collider is RigidBody3D:
			pass
	else:
		set_flag_off(CharacterFlag.GROUNDED)
		constant_force = Vector3.ZERO
