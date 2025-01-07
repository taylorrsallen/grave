@tool
class_name AmmoDisplay extends Node3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const AMMO_ROW_MESH = preload("res://systems/hud_3d/ammo_row_mesh.scn")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
# COMPOSITION
@onready var ammo_meshes: Node3D = $AmmoMeshes

# APPEARANCE
@export_category("Appearance")
@export var bullet_icon: Texture2D
@export var live_ammo_color: Color
@export var background_ammo_color: Color

# DATA
@export_category("Data")
@export var ammo: int = 20: set = _set_ammo
@export var max_ammo: int = 20: set = _set_max_ammo
@export var ammo_per_row: int = 10: set = _set_ammo_per_row

var live_ammo_meshes: Array[AmmoRowMesh]
var background_ammo_meshes: Array[AmmoRowMesh]

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _set_ammo(_ammo: int) -> void:
	ammo = clampi(_ammo, 0, max_ammo)
	if ammo_per_row < 1 || ammo_per_row > 100: return
	if max_ammo < 1 || max_ammo > 100: return
	_update_current_ammo_display()

func _set_max_ammo(_max_ammo: int) -> void:
	max_ammo = clampi(_max_ammo, 1, 1000)

func _set_ammo_per_row(_ammo_per_row: int) -> void:
	ammo_per_row = clampi(_ammo_per_row, 1, 100)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	regenerate_ammo_meshes()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _update_current_ammo_display() -> void:
	if live_ammo_meshes.is_empty(): return
	
	var ammo_left_to_display: int = ammo
	var ammo_left_in_max: int = max_ammo
	var i: int = 0
	while ammo_left_in_max > 0:
		var ammo_in_row: int = clampi(ammo_left_to_display, 0, ammo_per_row)
		live_ammo_meshes[i].ammo = ammo_in_row
		ammo_left_to_display = clampi(ammo_left_to_display - ammo_per_row, 0, 100)
		ammo_left_in_max -= ammo_per_row
		i += 1

func regenerate_ammo_meshes() -> void:
	if !is_instance_valid(ammo_meshes): return
	if !bullet_icon: return
	
	for child in ammo_meshes.get_children(): child.free()
	live_ammo_meshes = []
	background_ammo_meshes = []
	
	var ammo_left_to_display: int = max_ammo
	var i: int = 0
	while ammo_left_to_display > 0:
		var ammo_in_row: int = clampi(ammo_left_to_display, 0, ammo_per_row)
		
		var live_ammo_row_mesh: AmmoRowMesh = AMMO_ROW_MESH.instantiate()
		live_ammo_row_mesh.get_surface_override_material(0).albedo_color = live_ammo_color
		live_ammo_row_mesh.get_surface_override_material(0).albedo_texture = bullet_icon
		live_ammo_row_mesh.ammo = ammo_in_row
		live_ammo_row_mesh.position.y = bullet_icon.get_size().y * i * 0.01
		ammo_meshes.add_child(live_ammo_row_mesh)
		live_ammo_meshes.append(live_ammo_row_mesh)
		
		var background_ammo_row_mesh: AmmoRowMesh = AMMO_ROW_MESH.instantiate()
		background_ammo_row_mesh.get_surface_override_material(0).albedo_color = background_ammo_color
		background_ammo_row_mesh.get_surface_override_material(0).albedo_texture = bullet_icon
		background_ammo_row_mesh.ammo = ammo_in_row
		background_ammo_row_mesh.position.y = bullet_icon.get_size().y * i * 0.01
		background_ammo_row_mesh.position.z = -0.15
		ammo_meshes.add_child(background_ammo_row_mesh)
		background_ammo_meshes.append(background_ammo_row_mesh)
		
		ammo_left_to_display -= ammo_per_row
		i += 1
	
	_update_current_ammo_display()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
