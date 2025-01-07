class_name EquippableBase extends InteractableBase

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
var GUN_DATABASE: GunDatabase = load("res://resources/weapons/guns/gun_database.res")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var gun_data_id: int: set = _set_gun_data_id
@export var gun_data: GunData: set = _set_gun_data
@export var model: GunModel

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_gun_data_id(_gun_data_id: int) -> void:
	gun_data_id = _gun_data_id
	if gun_data_id == 0:
		gun_data = null
	else:
		gun_data = GUN_DATABASE.database[gun_data_id - 1]

func _set_gun_data(_gun_data: GunData) -> void:
	gun_data = _gun_data
	
	if is_instance_valid(model): model.queue_free()
	if !gun_data: return
	model = gun_data.model.instantiate()
	add_child.call_deferred(model)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	if gun_data_id: gun_data_id = gun_data_id

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func destroy() -> void:
	if multiplayer.is_server():
		queue_free()
	else:
		hide()
		collision_layer = 0
		process_mode = Node.PROCESS_MODE_DISABLED
		_rpc_destroy.rpc_id(1)

@rpc("any_peer", "call_remote", "unreliable")
func _rpc_destroy() -> void:
	queue_free()
