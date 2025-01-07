extends Node

var queue: Array[Dictionary] = []
var cache: Dictionary = {}

var calc_per_frame: int = 5

func _physics_process(_delta: float) -> void:
	for _i in calc_per_frame: _dequeue_area_query()

func request_area_query(requester: Node, pos: Vector3, radius: float, collision_mask: int, colliders_to_ignore: Array = []) -> void:
	var key: String = str(requester)
	if key in cache: return
	cache[key] = ""
	
	queue.push_back({
		"requester": requester,
		"pos": pos,
		"radius": radius,
		"collision_mask": collision_mask,
		"colliders_to_ignore": colliders_to_ignore,
		"key": key,
	})

func _dequeue_area_query() -> void:
	if queue.is_empty(): return
	var query_data: Dictionary = queue.pop_front()
	if is_instance_valid(query_data.requester):
		var results: Array[PhysicsBody3D] = query_area(query_data.pos, query_data.radius, query_data.collision_mask, query_data.colliders_to_ignore)
		query_data.requester.update_area_query(results)
	
	cache.erase(query_data.key)

func query_area(pos: Vector3, radius: float, collision_mask: int, _colliders_to_ignore: Array = []) -> Array[PhysicsBody3D]:
	var query_params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	var transform: Transform3D = Transform3D()
	transform.origin = pos
	query_params.transform = transform
	
	var sphere_shape: SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = radius
	query_params.shape = sphere_shape
	
	query_params.collision_mask = collision_mask
	var colliders_to_ignore: Array = []
	for collider in _colliders_to_ignore: if is_instance_valid(collider): colliders_to_ignore.append(collider)
	
	query_params.exclude = colliders_to_ignore
	
	var space_state: PhysicsDirectSpaceState3D = get_tree().root.world_3d.direct_space_state
	var results: Array[Dictionary] = space_state.intersect_shape(query_params)
	var hit_colliders: Array[PhysicsBody3D] = []
	for result in results: hit_colliders.append(result.collider)
	
	return hit_colliders
