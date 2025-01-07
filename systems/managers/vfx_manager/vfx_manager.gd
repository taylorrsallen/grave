extends Node

const VFX_DATABASE: VfxDatabase = preload("res://resources/vfx/vfx_database.res")

func spawn_vfx(vfx_id: int, position: Vector3, basis: Basis) -> void:
	_rpc_spawn_vfx.rpc(vfx_id, position, basis)

@rpc("any_peer", "call_local", "unreliable")
func _rpc_spawn_vfx(vfx_id: int, position: Vector3, basis: Basis) -> void:
	var vfx: Node3D = VFX_DATABASE.database[vfx_id].instantiate()
	
	vfx.position = position
	vfx.basis = basis
	get_tree().root.add_child(vfx)
