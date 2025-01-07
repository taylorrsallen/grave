extends Node

const BULLET_BASE = preload("res://systems/projectile/bullet_base.scn")

func spawn_client_owned_object(player_id: int, spawn_type: int, spawn_id: int, position: Vector3, basis: Basis) -> void:
	var bullet: BulletBase = BULLET_BASE.instantiate()
	bullet.position = position
	bullet.basis = basis
	bullet.set_multiplayer_authority(multiplayer.get_unique_id())
	var peer_connection: PeerConnection = Util.main.network_manager.try_get_local_peer_connection()
	if !peer_connection: return
	var player_controller: PlayerController = peer_connection.try_get_player_controller(player_id)
	if !player_controller: return
	player_controller.owned_objects.add_child(bullet, true)
	#rpc_spawn_client_owned_object.rpc(spawn_type, spawn_id, position, rotation, multiplayer.get_unique_id())

#func spawn_server_owned_object(spawn_type: int)

#@rpc("any_peer", "call_local", "unreliable")
#func rpc_spawn_client_owned_object(spawn_type: int, spawn_id: int, position: Vector3, rotation: Vector3, client_peer_id: int) -> void:
	#var bullet: BulletBase = BULLET_BASE.instantiate()
	#bullet.position = position
	#bullet.rotation = rotation
	#bullet.set_multiplayer_authority(client_peer_id)
	#Util.main.projectiles.add_child(bullet, true)
