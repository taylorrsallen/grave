class_name Spawner extends Marker3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
signal finished_spawning()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum SpawnMethod {
	ON_LOAD,
	CONTINUOUS,
}

enum SpawnType {
	PLAYER,
	ENEMY,
	EQUIPPABLE,
	PICKUP,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var spawn_method: SpawnMethod = SpawnMethod.ON_LOAD

@export var spawn_type: SpawnType
@export var spawn_id: int
@export var metadata: Dictionary = {}

@export var continuous_spawn_rate: float
@export var continuous_spawn_timer: float
@export var continuous_spawn_count: int = -1
var spawned: int

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	if !multiplayer.is_server(): return
	EventBus.game_started.connect(_on_game_started)

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	if spawn_method != SpawnMethod.CONTINUOUS: return
	if continuous_spawn_count > -1 && spawned >= continuous_spawn_count: return
	
	continuous_spawn_timer += delta
	if continuous_spawn_timer >= continuous_spawn_rate:
		continuous_spawn_timer = 0.0
		spawn()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _on_game_started() -> void:
	if spawn_method != SpawnMethod.ON_LOAD: return
	spawn()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func reset_spawned() -> void:
	spawned = 0

func spawn() -> void:
	spawned += 1
	SpawnManager.spawn_server_owned_object(spawn_type, spawn_id, metadata, global_position)
	if continuous_spawn_count > -1 && spawned >= continuous_spawn_count: finished_spawning.emit()
