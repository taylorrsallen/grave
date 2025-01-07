class_name Main extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@onready var peer_connections_box: HBoxContainer = $PeerConnectionsBox

@onready var network_manager: NetworkManager = $NetworkManager
@onready var npcs: Node = $NPCs
@onready var server_objects: Node = $ServerObjects
@onready var level: Node = $Level

@onready var v_box_container: VBoxContainer = $VBoxContainer

## DEBUG
@export var debug: bool = false

@onready var start_game: Button = $VBoxContainer/StartGame

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	network_manager.server_started.connect(_on_server_started)
	network_manager.state_changed.connect(_refresh_ui)
	Util.main = self
	
	#var peer_connection: PeerConnection = network_manager._create_peer_connection(1)
	#peer_connection.try_create_player_controller()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _on_host_pressed() -> void:
	network_manager.create_server()

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
func _on_join_pressed() -> void:
	network_manager.connect_to_server(line_edit.text)

func _on_disconnect_pressed() -> void:
	network_manager.disconnect_network()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _refresh_ui() -> void:
	for child in peer_connections_box.get_children(): child.queue_free()
	for child in network_manager.get_children():
		if !(child is PeerConnection): continue
		var peer_con_container: PanelContainer = PanelContainer.new()
		var peer_con_vbox: VBoxContainer = VBoxContainer.new()
		var peer_con_label: Label = Label.new()
		peer_con_label.text = child.name
		peer_connections_box.add_child(peer_con_container)
		peer_con_container.add_child(peer_con_vbox)
		peer_con_vbox.add_child(peer_con_label)
		
		if child.name.to_int() == multiplayer.get_unique_id():
			var owner_label: Label = Label.new()
			owner_label.text = "This is you!"
			peer_con_vbox.add_child(owner_label)

func _on_server_started() -> void:
	start_game.show()

func _on_start_game_pressed() -> void:
	EventBus.start_game()

func reset() -> void:
	for child in npcs.get_children():
		if child is MultiplayerSpawner: continue
		child.free()
	for child in server_objects.get_children():
		if child is MultiplayerSpawner: continue
		child.free()
