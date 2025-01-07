class_name CameraRig extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum ControlMode {
	STANDARD,
	SWIMMING,
}

enum Perspective {
	FPS,
	TPS,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## COMPOSITION
@onready var yaw: Node3D = $Yaw
@onready var spring_arm_3d: SpringArm3D = $Yaw/SpringArm3d
@onready var rotation_target: Node3D = $RotationTarget

@onready var camera_offset: Node3D = $Yaw/SpringArm3d/CameraOffset
@onready var animation_player: AnimationPlayer = $Yaw/SpringArm3d/CameraOffset/AnimationPlayer
@onready var camera_3d: Camera3D = $Yaw/SpringArm3d/CameraOffset/Camera3D
@onready var ray_cast_3d: RayCast3D = $Yaw/SpringArm3d/CameraOffset/Camera3D/RayCast3D

@export var anchor_node: Node3D: set = _set_anchor_node
var anchor_position: Vector3
@export var anchor_offset: Vector3
@export var zoom: float = 2.675

@export var mouse_look_sensitivity: float = 1.0
@export var gamepad_look_sensitivity: float = 3.5
@export var look_bounding: bool = true
@export var look_bounds: Vector2 = Vector2(-89.0, 89.0)

var focus_position: Vector3

var euler_rot: Vector3

@export var perspective: Perspective
var control_mode: ControlMode: set = _set_control_mode

@export var base_fov: float = 70.0
@export var fov_mod: float

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_control_mode(_control_mode: ControlMode) -> void:
	control_mode = _control_mode
	if control_mode == ControlMode.SWIMMING:
		look_bounding = false
	else:
		look_bounding = true

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _physics_process(delta: float) -> void:
	if perspective == Perspective.FPS:
		update_first_person_position(1.0)
	else:
		update_third_person_position(delta * 20.0)
	
	camera_3d.fov = lerpf(camera_3d.fov, base_fov + fov_mod, 4.0 * delta)

func _set_anchor_node(_anchor_node: Node3D) -> void:
	anchor_node = _anchor_node

func connect_animations(target: Node3D) -> void:
	if target.has_signal("jumped") && !target.jumped.is_connected(_on_character_jumped): target.jumped.connect(_on_character_jumped)
	if target.has_signal("landed") && !target.landed.is_connected(_on_character_landed): target.landed.connect(_on_character_landed)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func make_current() -> void: camera_3d.make_current()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func get_yaw_right() -> Vector3: return yaw.global_basis.x
func get_yaw_up() -> Vector3: return yaw.global_basis.y
func get_yaw_forward() -> Vector3: return -yaw.global_basis.z
func get_camera_up() -> Vector3: return camera_3d.global_basis.y
func get_camera_forward() -> Vector3: return -camera_3d.global_basis.z

func get_yaw_local_vector3(vector: Vector3) -> Vector3:
	return vector.x * get_yaw_right() + vector.y * get_yaw_up() + vector.z * -get_yaw_forward()

func get_camera_local_vector3(vector: Vector3) -> Vector3:
	return vector.x * get_yaw_right() + vector.y * get_camera_up() + vector.z * -get_camera_forward()

func get_aim_target() -> Vector3:
	if ray_cast_3d.is_colliding():
		return ray_cast_3d.get_collision_point()
	else:
		return get_fixed_aim_target()

func get_fixed_aim_target() -> Vector3:
	return camera_3d.global_position + get_camera_forward() * ray_cast_3d.target_position.length()

func get_look_up_down_scalar() -> float:
	return get_camera_forward().dot(get_yaw_up())

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func snap_to_position(_position: Vector3, _delta: float) -> void:
	global_position = lerp(global_position, _position + anchor_offset, _delta)

func snap_to_node(node: Node3D, _delta: float) -> void:
	global_position = lerp(global_position, node.global_position + node.basis.x * anchor_offset.x + node.basis.y * anchor_offset.y + -node.basis.z * anchor_offset.z, _delta)

func set_anchor_node(_anchor_node: Node3D) -> void:
	anchor_node = _anchor_node
	snap_to_node(anchor_node, 1.0)
	
func set_mouse_visible(_visible: bool) -> void:
	if _visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_focused_entity() -> Node3D:
	if ray_cast_3d.is_colliding():
		focus_position = ray_cast_3d.get_collision_point()
		return ray_cast_3d.get_collider()
	return null

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func update_first_person_position(delta: float) -> void:
	if is_instance_valid(anchor_node):
		snap_to_node(anchor_node, delta)
	else:
		snap_to_position(anchor_position, delta)
	spring_arm_3d.spring_length = 0.0

func update_third_person_position(delta: float) -> void:
	if is_instance_valid(anchor_node):
		snap_to_node(anchor_node, delta)
	else:
		snap_to_position(anchor_position, delta)
	spring_arm_3d.spring_length = zoom

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func apply_inputs(raw_move_input: Vector3, look_input: Vector2, delta: float) -> void:
	if control_mode == ControlMode.SWIMMING:
		add_rotation(Vector3(-raw_move_input.x, look_input.y, look_input.x))
	else:
		add_rotation(Vector3(look_input.x, look_input.y, 0.0) * delta * mouse_look_sensitivity)

func add_rotation(_rotation: Vector3) -> void:
	if control_mode == ControlMode.STANDARD:
		euler_rot.x += _rotation.y
		if look_bounding: euler_rot.x = clamp(euler_rot.x, look_bounds.x, look_bounds.y)
		euler_rot.y += _rotation.x
		euler_rot.z += _rotation.z
	else:
		yaw.basis = Basis.IDENTITY
		rotation_target.rotate_object_local(Vector3.FORWARD, -_rotation.z * 0.05)
		rotation_target.rotate_object_local(Vector3.RIGHT, _rotation.y * 0.05)
		rotation_target.rotate_object_local(Vector3.UP, _rotation.x * 0.05)
		spring_arm_3d.basis = spring_arm_3d.basis.orthonormalized().slerp(rotation_target.basis.orthonormalized(), 0.1).orthonormalized()
		
		## THIS DOESN'T WORK YET
		var _euler_rot: Vector3 = spring_arm_3d.global_basis.get_euler(0)
		euler_rot.x = rad_to_deg(_euler_rot.x)
		euler_rot.y = rad_to_deg(_euler_rot.y)
		euler_rot.z = rad_to_deg(_euler_rot.z)

func apply_camera_rotation() -> void:
	if control_mode == ControlMode.STANDARD:
		yaw.basis = get_yaw_rotation()
		spring_arm_3d.basis = get_pitch_rotation()
		rotation_target.basis = spring_arm_3d.global_basis

func get_yaw_rotation() -> Basis: return Basis.from_euler(Vector3(0.0, deg_to_rad(euler_rot.y), 0.0))
func get_pitch_rotation() -> Basis: return Basis.from_euler(Vector3(deg_to_rad(euler_rot.x), 0.0, 0.0))
func get_roll_rotation() -> Basis: return Basis.from_euler(Vector3(0.0, 0.0, deg_to_rad(euler_rot.z)))

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## ANIMATIONS
func _on_character_jumped() -> void: animation_player.play("jump")
func _on_character_landed(_force: float) -> void: animation_player.play("land")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## WATER
#func _on_area_3d_area_entered(area: Area3D) -> void:
	#if area is WaterVolume: water_entered.emit()
#
#func _on_area_3d_area_exited(area: Area3D) -> void:
	#if area is WaterVolume: water_exited.emit()
