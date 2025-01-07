class_name Util

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const UINT8_MAX  = (1 << 8)  - 1 # 255
const UINT16_MAX = (1 << 16) - 1 # 65535
const UINT32_MAX = (1 << 32) - 1 # 4294967295

const INT8_MIN  = -(1 << 7)  # -128
const INT16_MIN = -(1 << 15) # -32768
const INT32_MIN = -(1 << 31) # -2147483648
const INT64_MIN = -(1 << 63) # -9223372036854775808

const INT8_MAX  = (1 << 7)  - 1 # 127
const INT16_MAX = (1 << 15) - 1 # 32767
const INT32_MAX = (1 << 31) - 1 # 2147483647
const INT64_MAX = (1 << 63) - 1 # 9223372036854775807

## SERIALIZATION
const GAME_DIR: String = "res://"
const USER_DIR: String = "user://"

const SAVE_DIR: String = USER_DIR + "save/"
const USER_CONTENT_DIR: String = USER_DIR + "content/"

const RESOURCES_DIR: String = "resources/"
const ICONS_FOLDER: String = "icons/"
const GAME_MODES_FOLDER: String = "game_modes/"
const ITEMS_FOLDER: String = "items/"
const MAPS_FOLDER: String = "maps/"

const CHARACTERS_FOLDER: String = "characters/"

const WORLDS_FOLDER: String = "worlds/"
const TERRAIN_FOLDER: String = "terrain/"
const GAME_LEVELS_DIR: String = GAME_DIR + RESOURCES_DIR + WORLDS_FOLDER
const USER_LEVELS_DIR: String = USER_CONTENT_DIR + WORLDS_FOLDER

const ASSET_DIR: String = GAME_DIR + "assets/"
const RESOURCE_DIR: String = GAME_DIR + "resources/"
const ICONS_DIR: String = ASSET_DIR + ICONS_FOLDER

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static var main: Main

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
#static func get_player_controller(player_id: int) -> PlayerController:
	#if player_id == 0:
		#return Util.player
	#else:
		#return Util.extra_players[player_id - 1]
#
#static func get_player_character(player_id: int) -> Character:
	#var player_controller: PlayerController = get_player_controller(player_id)
	#if !is_instance_valid(player_controller): return null
	#return player_controller.character
#
#static func get_closest_player_character(global_coord: Vector3) -> Character:
	#var player_characters: Array[Character] = []
	#for i in 4:
		#var player_character: Character = get_player_character(i)
		#if is_instance_valid(player_character): player_characters.append(player_character)
	#
	#if player_characters.is_empty(): return null
	#
	#var closest_character: Character = null
	#var closest_distance: float = 100.0
	#for player_character in player_characters:
		#var distance: float = player_character.global_position.distance_to(global_coord)
		#if distance < closest_distance:
			#closest_character = player_character
			#closest_distance = distance
	#
	#return closest_character
#
#static func get_closest_player_controller(global_coord: Vector3) -> PlayerController:
	#var player_controllers: Array[PlayerController] = []
	#for i in 4:
		#var player_controller: PlayerController = get_player_controller(i)
		#if is_instance_valid(player_controller) && is_instance_valid(player_controller.character): player_controllers.append(player_controller)
	#
	#if player_controllers.is_empty(): return null
	#
	#var closest_controller: PlayerController = null
	#var closest_distance: float = 100.0
	#for player_controller in player_controllers:
		#var distance: float = player_controller.character.global_position.distance_to(global_coord)
		#if distance < closest_distance:
			#closest_controller = player_controller
			#closest_distance = distance
	#
	#return closest_controller

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func set_flag(mask: int, flag: int, active: bool) -> int:
	if active:
		return set_flag_on(mask, flag)
	else:
		return set_flag_off(mask, flag)

static func set_flag_on(mask: int, flag: int) -> int: return mask | (1 << flag)
static func set_flag_off(mask: int, flag: int) -> int: return mask & ~(1 << flag)
static func is_flag_on(mask: int, flag: int) -> bool: return (1 << flag) == mask & (1 << flag)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func verify_directory(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path)

## Returns an array of file names in directory
static func get_files_in_directory(directory: String) -> Array[String]:
	var files: Array[String] = []
	
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && !file_name.contains(".import"): files.append(file_name)
			file_name = dir.get_next()
	
	return files

## Returns an array of directory names in directory
static func get_directories_in_directory(directory: String) -> Array[String]:
	var directories: Array[String] = []
	
	var dir = DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir(): directories.append(file_name)
			file_name = dir.get_next()
	
	return directories

static func is_datetime_before_other(datetime: Dictionary, other: Dictionary) -> bool:
	if datetime["year"] < other["year"]:
		return true
	else: if datetime["year"] > other["year"]:
		return false

	if datetime["month"] < other["month"]:
		return true
	else: if datetime["month"] > other["month"]:
		return false

	if datetime["day"] < other["day"]:
		return true
	else: if datetime["day"] > other["day"]:
		return false

	if datetime["hour"] < other["hour"]:
		return true
	else: if datetime["hour"] > other["hour"]:
		return false

	if datetime["minute"] < other["minute"]:
		return true
	else: if datetime["minute"] > other["minute"]:
		return false

	if datetime["second"] < other["second"]:
		return true
	else: if datetime["second"] > other["second"]:
		return false

	return false

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func get_next_available_id(existing_ids: Array[int]) -> int:
	var next_available_id: int = 0
	while existing_ids.has(next_available_id): next_available_id += 1
	return next_available_id

static func get_serialized_name(name: String, id: int) -> String:
	return name.to_snake_case() + "#" + str(id)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func get_rect_dims_3d(a: Vector3i, b: Vector3i) -> Vector3i:
	return (a - b).abs()

static func get_taxicab_distance_3d(a: Vector3i, b: Vector3i) -> int:
	var distance: Vector3i = (a - b).abs()
	return distance.x + distance.y + distance.z

static func get_nearest_taxicab_value_3d(from: Array[Vector3i], to: Vector3i) -> Vector3i:
	var nearest_value: Vector3i
	var nearest_distance: int = INT64_MAX
	for coord in from:
		var distance: int = get_taxicab_distance_3d(coord, to)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_value = coord
	
	return nearest_value

static func get_nearest_taxicab_distance_3d(from: Array[Vector3i], to: Vector3i) -> int:
	var nearest_distance: int = INT64_MAX
	for coord in from:
		var distance: int = get_taxicab_distance_3d(coord, to)
		if distance < nearest_distance: nearest_distance = distance
	
	return nearest_distance

static func get_taxicab_distance_2d(a: Vector2i, b: Vector2i) -> int:
	var distance: Vector2i = (a - b).abs()
	return distance.x + distance.y

static func get_nearest_taxicab_distance_2d(from: Array[Vector2i], to: Vector2i) -> int:
	var nearest_distance: int = INT64_MAX
	for coord in from:
		var distance: int = get_taxicab_distance_2d(coord, to)
		if distance < nearest_distance: nearest_distance = distance
	
	return nearest_distance

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func get_yaw_angle_and_dot_to_target(from: Node3D, to: Vector3) -> Vector2:
	var direction_to_target: Vector3 = from.global_position * Vector3(1.0, 0.0, 1.0) - to * Vector3(1.0, 0.0, 1.0)
	var angle_to_target: float = (from.global_basis.z * Vector3(1.0, 0.0, 1.0)).angle_to(direction_to_target)
	var dot_to_target: float = (from.global_basis.x * Vector3(1.0, 0.0, 1.0)).dot(direction_to_target.normalized())
	return Vector2(angle_to_target, dot_to_target)

static func get_pitch_angle_and_dot_to_target(from_yaw_forward: Vector3, from: Node3D, to: Node3D, to_height_offset: float) -> Vector2:
	var distance_to_target: float = (from.global_position * Vector3(1.0, 0.0, 1.0)).distance_to(to.global_position * Vector3(1.0, 0.0, 1.0))
	var aim_target: Vector3 = from_yaw_forward.normalized() * distance_to_target + from.global_position * Vector3(1.0, 0.0, 1.0)
	aim_target.y = to.global_position.y + to_height_offset
	
	var direction_to_target: Vector3 = from.global_position - aim_target
	var angle_to_target: float = (from.global_basis.z).angle_to(direction_to_target)
	var dot_to_target: float = (-from.global_basis.y).dot(direction_to_target)
	return Vector2(angle_to_target, dot_to_target)

static func rotate_yaw_to_target(delta: float, from: Node3D, to: Vector3) -> Vector2:
	var yaw_angle_dot: Vector2 = Util.get_yaw_angle_and_dot_to_target(from, to)
	from.rotate(Vector3.UP, sign(yaw_angle_dot.y) * min(delta, yaw_angle_dot.x))
	return yaw_angle_dot

static func rotate_pitch_to_target(delta: float, from_yaw_forward: Vector3, from: Node3D, to: Node3D, to_height_offset: float) -> Vector2:
	var pitch_angle_dot: Vector2 = Util.get_pitch_angle_and_dot_to_target(from_yaw_forward, from, to, to_height_offset)
	from.rotate(Vector3.RIGHT, sign(pitch_angle_dot.y) * min(delta, pitch_angle_dot.x))
	return pitch_angle_dot

static func shortest_rotation(from: Quaternion, to: Quaternion) -> Quaternion:
	if from.dot(to) < 0.0:
		return from * (to * -1.0).inverse()
	else:
		return from * to.inverse()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
static func round_to_dec(num: float, digit: float) -> float:
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
