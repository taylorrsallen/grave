class_name PickupBase extends InteractableBase

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum PickupType {
	AMMO,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var id: int: set = _set_id
@export var model: Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_id(_id: int) -> void:
	id = _id
	_update_model()

func _update_model() -> void:
	if is_instance_valid(model): model.queue_free()
	model = null
	
	if metadata.has("ammo") && id <= Util.BULLET_DATABASE.database.size():
		model = Util.BULLET_DATABASE.database[id].ammo_box_model.instantiate()
	
	if model: add_child.call_deferred(model)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func pickup(character: Character) -> void:
	if metadata.has("ammo"): character.inventory.ammo_stock[id] += metadata["ammo"]
	
	destroy()

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
