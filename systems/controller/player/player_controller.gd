class_name PlayerController extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum PlayerControllerFlag {
	CURSOR_VISIBLE,
	MENU_VISIBLE,
}

enum {
	CONTROL_KEYBOARD,
	CONTROL_SONY,
	CONTROL_NINTENDO,
	CONTROL_XBOX,
}

const CAMERA_RIG_SCN: PackedScene = preload("res://systems/camera/camera_rig.scn")
const SPLITSCREEN_VIEW_SCN: PackedScene = preload("res://systems/controller/player/splitscreen_view.scn")
const SHADER_VIEW_SCN: PackedScene = preload("res://systems/controller/player/shader_view.scn")


# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## DATA
@export var local_id: int

## INPUT
var controls_assigned: int = -1
var device_assigned: int = -1

@export var move_input: Vector2
@export var raw_move_input: Vector3
@export var world_move_input: Vector3

## COMPOSITION
@onready var character: Character = $Character
@export var camera_rig: CameraRig
@onready var label_3d: Label3D = $Character/Label3D
@onready var owned_objects: Node = $OwnedObjects

## VIEW
@onready var camera_view_layer: CanvasLayer = $CameraViewLayer
@export var splitscreen_view: SplitscreenView
@onready var shader_view_layer: CanvasLayer = $ShaderViewLayer
@export var shader_view: Control
#@onready var menu_view: Control = $HUDViewLayer/MenuView

## FLAGS
@export var flags: int

## INTERACTABLE
@export var focused_equippable: EquippableBase
@export var desire_to_equip: float
@export var max_desire_to_equip: float = 0.65

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func is_flag_on(flag: PlayerControllerFlag) -> bool: return Util.is_flag_on(flags, flag)
func set_flag_on(flag: PlayerControllerFlag) -> void: flags = Util.set_flag_on(flags, flag)
func set_flag_off(flag: PlayerControllerFlag) -> void: flags = Util.set_flag_off(flags, flag)
func set_flag(flag: PlayerControllerFlag, active: bool) -> void: flags = Util.set_flag(flags, flag, active)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func init() -> void:
	#Util.main.game_started.connect(_on_game_started)
	
	spawn_camera_rig()
	if local_id == 0:
		assign_default_controls(0)
		set_cursor_captured()

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().name.to_int())

func _ready() -> void:
	if is_multiplayer_authority(): init()
	
	label_3d.text = str(get_multiplayer_authority())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("start_" + str(local_id)): toggle_cursor_visible()
		
		if local_id == 0:
			if !get_window().has_focus():
				set_cursor_visible()
			#elif menu_view.get_children().is_empty():
				#if is_flag_on(PlayerControllerFlag.CURSOR_VISIBLE): set_cursor_captured()
			#else:
				#set_cursor_visible()
		
			#if Input.is_action_just_pressed("start_0"):
				#if menu_view.get_children().is_empty():
					#menu_view.add_child(START_MENU.instantiate())
				#else:
					#for child in menu_view.get_children():
						#child.go_back()
		
		move_input = Input.get_vector("move_left_" + str(local_id), "move_right_" + str(local_id), "move_forward_" + str(local_id), "move_back_" + str(local_id))
		raw_move_input = Vector3(move_input.x, 1.0 if Input.is_action_pressed("jump_" + str(local_id)) else 0.0, move_input.y)
		world_move_input = camera_rig.get_yaw_local_vector3(raw_move_input)
		
		if !is_flag_on(PlayerControllerFlag.CURSOR_VISIBLE):
			var look_movement: Vector2 = Vector2.ZERO
			if local_id == 0:
				var cursor_movement: Vector2 = (get_viewport().size * 0.5).floor() - get_viewport().get_mouse_position()
				get_viewport().warp_mouse((get_viewport().size * 0.5).floor())
				look_movement += cursor_movement
			
			#var gamepad_look_input: Vector2 = Input.get_vector("look_left_" + str(local_id), "look_right_" + str(local_id), "look_down_" + str(local_id), "look_up_" + str(local_id)) * 4.0 * camera_rig.gamepad_look_sensitivity
			#gamepad_look_input.x = -gamepad_look_input.x
			#look_movement += gamepad_look_input
			
			camera_rig.apply_inputs(raw_move_input, look_movement, delta)
			camera_rig.apply_camera_rotation()
		
		if is_instance_valid(character):
			character.world_move_input = world_move_input
			character.look_in_direction(camera_rig.camera_3d.global_basis, delta)
			
			character.gun_barrel_position_target = camera_rig.camera_3d.global_position - camera_rig.camera_3d.global_basis.z * 0.4 + camera_rig.camera_3d.global_basis.x * 0.3 - camera_rig.camera_3d.global_basis.y * 0.2
			
			if Input.is_action_pressed("equip_" + str(local_id)):
				desire_to_equip = clampf(desire_to_equip + delta, 0.0, max_desire_to_equip)
			else:
				desire_to_equip = 0.0
			
			if Input.is_action_pressed("sprint_" + str(local_id)):
				if !character.is_flag_on(Character.CharacterFlag.SPRINT): character.set_flag_on(Character.CharacterFlag.SPRINT)
			else:
				if character.is_flag_on(Character.CharacterFlag.SPRINT): character.set_flag_off(Character.CharacterFlag.SPRINT)
			
			camera_rig.ray_cast_3d.force_raycast_update()
			if camera_rig.ray_cast_3d.is_colliding():
				character.gun_barrel_look_target = camera_rig.ray_cast_3d.get_collision_point()
			else:
				character.gun_barrel_look_target = camera_rig.camera_3d.global_position + camera_rig.get_camera_forward() * 100.0
			
			if Input.is_action_pressed("primary_" + str(local_id)): character.gun_base.try_fire(local_id, character, delta)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# CURSOR
func toggle_cursor_visible() -> void:
	if !is_flag_on(PlayerControllerFlag.CURSOR_VISIBLE):
		set_cursor_visible()
	else:
		set_cursor_captured()

func set_cursor_visible() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_flag_on(PlayerControllerFlag.CURSOR_VISIBLE)

func set_cursor_captured() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if is_flag_on(PlayerControllerFlag.CURSOR_VISIBLE):
		get_viewport().warp_mouse(get_viewport().size * 0.5)
		set_flag_off(PlayerControllerFlag.CURSOR_VISIBLE)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# SPLITSCREEN
func update_splitscreen_view(player_count: int, horizontal: bool = true) -> void:
	match player_count:
		1: _set_view_anchors()
		2: _update_2_player_splitscreen_view(horizontal)
		3: _update_3_player_splitscreen_view(horizontal)
		4: _update_4_player_splitscreen_view()
		_: pass

# ------------------------------------------------------------------------------------------------
# PRIVATE SPLITSCREEN
func _set_view_anchors(left: float = 0.0, right: float = 1.0, bottom: float = 1.0, top: float = 0.0) -> void:
	_set_control_view_anchors(splitscreen_view, left, right, bottom, top)
	_set_control_view_anchors(shader_view, left, right, bottom, top)
	#_set_control_view_anchors(hud_view, left, right, bottom, top)
	#_set_control_view_anchors(gui_3d_view, left, right, bottom, top)

func _set_control_view_anchors(control: Control, left: float = 0.0, right: float = 1.0, bottom: float = 1.0, top: float = 0.0) -> void:
	control.anchor_left = left
	control.anchor_top = top
	control.anchor_right = right
	control.anchor_bottom = bottom

func _update_2_player_splitscreen_view(horizontal: bool) -> void:
	if local_id == 0:
		if horizontal:
			_set_view_anchors(0.0, 1.0, 0.5, 0.0)
		else:
			_set_view_anchors(0.0, 0.5, 1.0, 0.0)
	else:
		if horizontal:
			_set_view_anchors(0.0, 1.0, 1.0, 0.5)
		else:
			_set_view_anchors(0.5, 1.0, 1.0, 0.0)

func _update_3_player_splitscreen_view(horizontal: bool) -> void:
	match local_id:
		0:
			if horizontal:
				_set_view_anchors(0.0, 1.0, 0.5, 0.0)
			else:
				_set_view_anchors(0.0, 0.5, 1.0, 0.0)
		1:
			if horizontal:
				_set_view_anchors(0.0, 0.5, 1.0, 0.5)
			else:
				_set_view_anchors(0.5, 1.0, 0.5, 0.0)
		2: _set_view_anchors(0.5, 1.0, 1.0, 0.5)

func _update_4_player_splitscreen_view() -> void:
	match local_id:
		0: _set_view_anchors(0.0, 0.5, 0.5, 0.0)
		1: _set_view_anchors(0.5, 1.0, 0.5, 0.0)
		2: _set_view_anchors(0.0, 0.5, 1.0, 0.5)
		3: _set_view_anchors(0.5, 1.0, 1.0, 0.5)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# CAMERA
func _init_camera_rig() -> void:
	if is_instance_valid(character):
		camera_rig.anchor_node = character
		
		#if camera_rig.perspective == Perspective.FPS:
			#camera_rig.anchor_node = character.get_eye_target()
		#else:
			#camera_rig.anchor_node = character.camera_socket
		
		camera_rig.connect_animations(character)
	
	camera_rig.make_current()
	#camera_rig.zoom = 20.0
	#camera_rig.zoom = 2.675
	
	camera_rig.spring_arm_3d.position.x = 0.0
	
	for i in 4:
		if i == local_id: continue
		camera_rig.camera_3d.cull_mask &= ~(1 << (15 + i))
	
	#camera_rig.anchor_position = Util.main.spawn_point + Vector3.UP

func set_camera_rig(_camera_rig: CameraRig) -> void:
	camera_rig = _camera_rig
	_init_camera_rig()

func spawn_camera_rig() -> void:
	splitscreen_view = SPLITSCREEN_VIEW_SCN.instantiate()
	
	# TOGGLE
	if !Util.main.debug: camera_view_layer.add_child(splitscreen_view)
	
	shader_view = SHADER_VIEW_SCN.instantiate()
	shader_view_layer.add_child(shader_view)
	
	camera_rig = CAMERA_RIG_SCN.instantiate()
	
	if !Util.main.debug:
		splitscreen_view.sub_viewport.add_child(camera_rig)
	else:
		camera_view_layer.add_child(camera_rig)
	
	_init_camera_rig()
	
	#if is_instance_valid(hud): hud.queue_free()
	#hud = HUD_GUI.instantiate()
	#hud_view.add_child(hud)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# INPUT
func assign_default_controls(control_type: int, device: int = 0) -> void:
	PlayerController.assign_default_controls_by_id(local_id, control_type, device)
	controls_assigned = control_type
	device_assigned = device

static func assign_default_controls_by_id(player_id: int, control_type: int, device: int = 0) -> void:
	match control_type:
		0: _assign_default_keyboard_controls(player_id)
		1: _assign_default_gamepad_sony_controls(player_id, device)
		2: _assign_default_gamepad_nintendo_controls(player_id, device)
		3: _assign_default_gamepad_xbox_controls(player_id, device)

# ------------------------------------------------------------------------------------------------
# PRIVATE INPUT

# HELPERS
static func _assign_key_action_event(player_id: int, action: String, keycode: Key) -> void:
	var input_event_key: InputEventKey = InputEventKey.new()
	input_event_key.keycode = keycode
	InputMap.action_erase_events(action + "_" + str(player_id))
	InputMap.action_add_event(action + "_" + str(player_id), input_event_key)

static func _assign_mouse_button_action_event(player_id: int, action: String, button: MouseButton) -> void:
	var input_event_mouse_button: InputEventMouseButton = InputEventMouseButton.new()
	input_event_mouse_button.button_index = button
	InputMap.action_erase_events(action + "_" + str(player_id))
	InputMap.action_add_event(action + "_" + str(player_id), input_event_mouse_button)

static func _assign_gamepad_button_action_event(player_id: int, device: int, action: String, button: JoyButton) -> void:
	var input_event_joypad_button: InputEventJoypadButton = InputEventJoypadButton.new()
	input_event_joypad_button.button_index = button
	input_event_joypad_button.device = device
	InputMap.action_erase_events(action + "_" + str(player_id))
	InputMap.action_add_event(action + "_" + str(player_id), input_event_joypad_button)

static func _assign_gamepad_motion_action_event(player_id: int, device: int, action: String, axis: JoyAxis, value: float) -> void:
	var input_event_joypad_motion: InputEventJoypadMotion = InputEventJoypadMotion.new()
	input_event_joypad_motion.axis = axis
	input_event_joypad_motion.axis_value = value
	input_event_joypad_motion.device = device
	InputMap.action_erase_events(action + "_" + str(player_id))
	InputMap.action_add_event(action + "_" + str(player_id), input_event_joypad_motion)

# DEFAULTS
static func _assign_default_keyboard_controls(player_id: int) -> void:
	## Move
	_assign_key_action_event(player_id, "move_left", KEY_A)
	_assign_key_action_event(player_id, "move_right", KEY_D)
	_assign_key_action_event(player_id, "move_back", KEY_S)
	_assign_key_action_event(player_id, "move_forward", KEY_W)
	
	## No look for KBM
	
	## Action inputs
	_assign_mouse_button_action_event(player_id, "primary", MOUSE_BUTTON_LEFT)
	_assign_mouse_button_action_event(player_id, "secondary", MOUSE_BUTTON_RIGHT)
	#_assign_mouse_button_action_event(player_id, "zoom_in", MOUSE_BUTTON_WHEEL_UP)
	#_assign_mouse_button_action_event(player_id, "zoom_out", MOUSE_BUTTON_WHEEL_DOWN)
	_assign_key_action_event(player_id, "reload", KEY_R)
	_assign_key_action_event(player_id, "reload", KEY_V)
	_assign_key_action_event(player_id, "sprint", KEY_SHIFT)
	_assign_key_action_event(player_id, "fire_mode_toggle", KEY_T)
	_assign_key_action_event(player_id, "equip", KEY_E)
	_assign_key_action_event(player_id, "jump", KEY_SPACE)
	#_assign_key_action_event(player_id, "sprint", KEY_SHIFT)
	#_assign_key_action_event(player_id, "interact", KEY_E)
	#_assign_key_action_event(player_id, "recipes", KEY_TAB)
	
	## Menu inputs
	_assign_key_action_event(player_id, "start", KEY_ESCAPE)

static func _assign_default_gamepad_axis_controls(player_id: int, device: int) -> void:
	_assign_gamepad_motion_action_event(player_id, device, "move_left", JOY_AXIS_LEFT_X, -1.0)
	_assign_gamepad_motion_action_event(player_id, device, "move_right", JOY_AXIS_LEFT_X, 1.0)
	_assign_gamepad_motion_action_event(player_id, device, "move_back", JOY_AXIS_LEFT_Y, 1.0)
	_assign_gamepad_motion_action_event(player_id, device, "move_forward", JOY_AXIS_LEFT_Y, -1.0)
	
	_assign_gamepad_motion_action_event(player_id, device, "look_left", JOY_AXIS_RIGHT_X, -1.0)
	_assign_gamepad_motion_action_event(player_id, device, "look_right", JOY_AXIS_RIGHT_X, 1.0)
	_assign_gamepad_motion_action_event(player_id, device, "look_down", JOY_AXIS_RIGHT_Y, 1.0)
	_assign_gamepad_motion_action_event(player_id, device, "look_up", JOY_AXIS_RIGHT_Y, -1.0)

static func _assign_default_gamepad_common_controls(player_id: int, device: int) -> void:
	_assign_default_gamepad_axis_controls(player_id, device)
	
	_assign_gamepad_button_action_event(player_id, device, "zoom_in", JOY_BUTTON_DPAD_UP)
	_assign_gamepad_button_action_event(player_id, device, "zoom_out", JOY_BUTTON_DPAD_DOWN)
	#if player_id == 0: _assign_gamepad_button_action_event(player_id, device, "start", JOY_BUTTON_START)

static func _assign_default_gamepad_sony_controls(player_id: int, device: int) -> void:
	_assign_default_gamepad_common_controls(player_id, device)
	
	_assign_gamepad_button_action_event(player_id, device, "primary", JOY_BUTTON_A) # CROSS
	_assign_gamepad_button_action_event(player_id, device, "secondary", JOY_BUTTON_B) # CIRCLE
	_assign_gamepad_button_action_event(player_id, device, "sprint", JOY_BUTTON_RIGHT_SHOULDER)
	_assign_gamepad_button_action_event(player_id, device, "interact", JOY_BUTTON_X) # SQUARE
	_assign_gamepad_button_action_event(player_id, device, "recipes", JOY_BUTTON_LEFT_SHOULDER)
	
	#_assign_gamepad_button_action_event(player_id, device, "primary", JOY_BUTTON_Y) # TRIANGLE

static func _assign_default_gamepad_nintendo_controls(player_id: int, device: int) -> void:
	_assign_default_gamepad_common_controls(player_id, device)
	
	_assign_gamepad_button_action_event(player_id, device, "primary", JOY_BUTTON_X) # A
	_assign_gamepad_button_action_event(player_id, device, "secondary", JOY_BUTTON_A) # B
	_assign_gamepad_button_action_event(player_id, device, "sprint", JOY_BUTTON_RIGHT_SHOULDER)
	_assign_gamepad_button_action_event(player_id, device, "interact", JOY_BUTTON_Y) # X
	_assign_gamepad_button_action_event(player_id, device, "recipes", JOY_BUTTON_LEFT_SHOULDER)

static func _assign_default_gamepad_xbox_controls(player_id: int, device: int) -> void:
	_assign_default_gamepad_common_controls(player_id, device)
	
	_assign_gamepad_button_action_event(player_id, device, "primary", JOY_BUTTON_A) # CROSS
	_assign_gamepad_button_action_event(player_id, device, "secondary", JOY_BUTTON_B) # CIRCLE
	_assign_gamepad_button_action_event(player_id, device, "sprint", JOY_BUTTON_RIGHT_SHOULDER)
	_assign_gamepad_button_action_event(player_id, device, "interact", JOY_BUTTON_X) # SQUARE
	_assign_gamepad_button_action_event(player_id, device, "recipes", JOY_BUTTON_LEFT_SHOULDER)
