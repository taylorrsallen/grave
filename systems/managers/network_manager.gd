class_name NetworkManager extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
signal state_changed()
signal server_started()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const PEER_CONNECTION: PackedScene = preload("res://systems/controller/player/peer_connection.scn")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const PORT: int = 27490

static var max_clients: int = 16

var connected_peer_ids: Array[int] = []
var state_check_timer: float
var state_check_cd: float = 0.5

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _physics_process(delta: float) -> void:
	state_check_timer += delta
	if state_check_timer >= state_check_cd:
		state_check_timer -= state_check_cd
		
		var current_peer_ids: Array[int] = []
		for child in get_children():
			if !(child is PeerConnection): continue
			current_peer_ids.append(child.name.to_int())
		current_peer_ids.sort()
		
		if current_peer_ids.size() != connected_peer_ids.size():
			connected_peer_ids = current_peer_ids
			state_changed.emit()
			return
		
		for i in current_peer_ids.size():
			if current_peer_ids[i] != connected_peer_ids[i]:
				connected_peer_ids = current_peer_ids
				state_changed.emit()
				return

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func create_server() -> void:
	if multiplayer.multiplayer_peer: disconnect_network()
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	
	var status = peer.create_server(PORT, max_clients)
	if status != Error.OK:
		printerr("Server could not be created.")
		return
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	
	_create_peer_connection(1)
	
	server_started.emit()
	print("Server started.")

func connect_to_server(ip_address: String = "127.0.0.1") -> void:
	if multiplayer.multiplayer_peer: disconnect_network()
	
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	
	var status = peer.create_client(ip_address, PORT)
	if status != Error.OK:
		printerr("Client could not be created.")
		return
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer

func disconnect_network() -> void:
	Util.main.reset()
	
	multiplayer.multiplayer_peer = null
	
	if multiplayer.peer_connected.is_connected(_on_peer_connected): multiplayer.peer_connected.disconnect(_on_peer_connected)
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected): multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)
	if multiplayer.connected_to_server.is_connected(_on_connected_to_server): multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	if multiplayer.server_disconnected.is_connected(_on_server_disconnected): multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	if multiplayer.connection_failed.is_connected(_on_connection_failed): multiplayer.connection_failed.disconnect(_on_connection_failed)
	
	for child in get_children(): if child is PeerConnection: child.free()
	
	state_changed.emit()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
## Returns null if the PeerConnection does not exist
func try_get_peer_connection(peer_id: int) -> PeerConnection:
	var peer_connection: PeerConnection = get_node_or_null(str(peer_id))
	#if !peer_connection: printerr("Could not find PeerConnection<%s>" % str(peer_id))
	return peer_connection

## Returns null if PeerConnection or PlayerController does not exist
func try_get_player_controller(peer_id: int, player_id: int) -> PlayerController:
	var peer_connection: PeerConnection = try_get_peer_connection(peer_id)
	if !peer_connection: return null
	return peer_connection.try_get_player_controller(player_id)

## Returns null if the PeerConnection does not exist
func try_get_local_peer_connection() -> PeerConnection:
	var peer_connection: PeerConnection = get_node_or_null(str(multiplayer.get_unique_id()))
	#if !peer_connection: printerr("Could not find PeerConnection<%s>" % str(peer_id))
	return peer_connection

## Returns null if PlayerController does not exist
func try_get_local_player_controller(player_id: int) -> PlayerController:
	var peer_connection: PeerConnection = try_get_peer_connection(multiplayer.get_unique_id())
	if !peer_connection: return null
	return peer_connection.try_get_player_controller(player_id)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server(): _create_peer_connection(peer_id)
	
	print("[Peer<%s>]: Peer<%s> connected." % [multiplayer.get_unique_id(), peer_id])

func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server(): get_node(str(peer_id)).free()
	print("[Peer<%s>]: Peer<%s> disconnected." % [multiplayer.get_unique_id(), peer_id])

## CLIENT ONLY
func _on_connected_to_server() -> void:
	print("[Peer<%s>]: Connection succeeded." % multiplayer.get_unique_id())

func _on_server_disconnected() -> void:
	print("[Peer<%s>]: Lost connection to server." % multiplayer.get_unique_id())
	
	disconnect_network()

func _on_connection_failed() -> void:
	print("[Peer<%s>]: Connection failed." % multiplayer.get_unique_id())
	
	disconnect_network()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _create_peer_connection(peer_id: int) -> PeerConnection:
	var peer_connection: PeerConnection = PEER_CONNECTION.instantiate()
	peer_connection.name = str(peer_id)
	add_child(peer_connection)
	return peer_connection
