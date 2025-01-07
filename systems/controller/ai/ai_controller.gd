class_name AIController extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var character: Character

@export var shots_per_second: float = 0.1
var shots_timer: float


# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	if !is_instance_valid(character): return
	
	var peer_connections: Array[PeerConnection] = []
	for child in Util.main.network_manager.get_children():
		if child is PeerConnection: peer_connections.append(child)
	
	if peer_connections.is_empty(): return
	
	var player_characters: Array[Character] = []
	for peer_connection in peer_connections:
		for child in peer_connection.get_children():
			if !(child is PlayerController): continue
			if is_instance_valid(child.character):
				player_characters.append(child.character)
				continue
			var non_server_character: Character = child.owned_objects.get_node_or_null("Character")
			if is_instance_valid(non_server_character): player_characters.append(non_server_character)
	
	if player_characters.is_empty(): return
	
	var closest_player_character: Character = null
	var closest_player_distance: float = 1000.0
	for player_character in player_characters:
		var distance: float = player_character.global_position.distance_to(character.global_position)
		if distance >= closest_player_distance: continue
		closest_player_character = player_character
		closest_player_distance = distance
	
	if !closest_player_character: return
	
	_update_target_character(closest_player_character, delta)
	


func _update_target_character(target_character: Character, delta: float) -> void:
	var look_transform: Transform3D = Transform3D(Basis.IDENTITY, character.global_position)
	look_transform = look_transform.looking_at(target_character.global_position)
	
	character.look_in_direction(look_transform.basis, delta)
	character.gun_barrel_look_target = target_character.global_position
	character.gun_barrel_position_target = character.global_position - look_transform.basis.z * 0.4 + look_transform.basis.x * 0.3 - look_transform.basis.y * 0.2
	
	
	var should_move_closer: bool = false
	var should_fire: bool = false
	
	var space_state: PhysicsDirectSpaceState3D = character.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(character.gun_base.global_position, character.global_position - look_transform.basis.z * 50.0, 3, [character.get_rid()])
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.has("collider") && is_instance_valid(result["collider"]) && result["collider"] == target_character:
		var distance: float = character.global_position.distance_to(target_character.global_position)
		should_move_closer = distance > 20.0
		should_fire = distance < 30.0
	else:
		should_move_closer = true
	
	if should_move_closer:
		character.navigation_agent_3d.target_position = target_character.global_position
		var next_nav_point = character.navigation_agent_3d.get_next_path_position()
		character.world_move_input = (next_nav_point - character.global_position).normalized()
	else:
		character.world_move_input = Vector3.ZERO
	
	if should_fire:
		shots_timer += randf_range(delta, delta * 0.5)
		if shots_timer >= shots_per_second:
			shots_timer = 0.0
			character.gun_base.try_fire_single_press(0, character, delta)
			if character.gun_base.rounds == 0:
				character.gun_base.try_reload()
