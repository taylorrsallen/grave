class_name PeerConnection extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const PLAYER_CONTROLLER = preload("res://systems/controller/player/player_controller.scn")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var player_controllers: Array[PlayerController] = []

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority(): try_create_player_controller()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func try_create_player_controller() -> PlayerController:
	if player_controllers.size() == 4: return null
	var player_controller: PlayerController = PLAYER_CONTROLLER.instantiate()
	player_controller.local_id = player_controllers.size()
	player_controller.name = "Player" + str(player_controller.local_id)
	player_controllers.append(player_controller)
	add_child(player_controller)
	return player_controller

func remove_player_controller(player_id: int) -> void:
	var player_to_remove: PlayerController = player_controllers.pop_at(player_id)
	player_to_remove.queue_free()
	
	for i in player_controllers.size():
		player_controllers[i].local_id = i
		player_controllers[i].name = "Player" + str(i)
		player_controllers[i].update_splitscreen_view(player_controllers.size())

## Returns null if PlayerController does not exist
func try_get_player_controller(player_id: int) -> PlayerController:
	if get_children().size() - 1 <= player_id:
		printerr("PeerConnection<%s>: Could not find PlayerController<%s>" % [name, str(player_id)])
		return null
	
	for child in get_children():
		if !(child is PlayerController): continue
		if child.local_id == player_id: return child
	
	return null
