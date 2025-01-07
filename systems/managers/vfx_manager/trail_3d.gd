class_name Trail3D extends MeshInstance3D

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
var _points = [] ## Stores all 3D positions that will make up the trail
var _widths = [] ## Stores all calculated widths using the positions of the points
var _lifespans = [] ## Stores all the trail points lifespans

@export var _trail_enabled: bool = true ## Is trail allowed to be shown

@export var _from_width: float = 0.5 ## Starting width of the trail
@export var _to_width: float = 0.0 ## End width of the trail
@export_range(0.5, 1.5) var _scale_acceleration: float = 1.0 ## Speed of the scaling

#@export var _motion_delta: float = 0.1 ## Sets the smoothness of the trail, how long it will take for a new trail piece to be made
@export var _lifespan: float = 1.0 ## Sets the duration until this part of the trail is no longer used, and is thus removed

@export var _start_color: Color = Color(1.0, 1.0, 1.0, 1.0) ## Starting color of the trail
@export var _end_color: Color = Color(1.0, 1.0, 1.0, 0.0) ## Ending color of the trail

var _old_pos: Vector3

@export var append_point_time: float = 0.025
var append_point_timer: float

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _ready() -> void:
	_old_pos = global_position
	mesh = ImmediateMesh.new()

func _physics_process(delta: float) -> void:
	if _trail_enabled: append_point_timer += delta
	if append_point_timer >= append_point_time:
		append_point_timer -= append_point_time
		append_point()
		_old_pos = global_position
	
	#if (_old_pos - global_position).length() > _motion_delta && _trail_enabled:
		#append_point()
		#_old_pos = global_position
	
	var p: int = 0
	var max_points: int = _points.size()
	while p < max_points:
		_points[p].y += delta * randf_range(0.5, 1.0)
		_lifespans[p] += delta
		if _lifespans[p] > _lifespan:
			remove_point(p)
			p -= 1
			if p < 0: p = 0
		
		max_points = _points.size()
		p += 1
	
	mesh.clear_surfaces()
	
	if _points.size() < 2: return
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(_points.size()):
		var t: float = float(i) / (_points.size() - 1.0)
		var current_color: Color = _start_color.lerp(_end_color, 1.0 - t)
		mesh.surface_set_color(current_color)
		
		var current_width = _widths[i][0] - pow(1.0 - t, _scale_acceleration) * _widths[i][1]
		
		var t0: float = i / _points.size()
		var t1: float = t
		
		mesh.surface_set_uv(Vector2(t0, 0.0))
		mesh.surface_add_vertex(to_local(_points[i] + current_width))
		mesh.surface_set_uv(Vector2(t1, 1.0))
		mesh.surface_add_vertex(to_local(_points[i] - current_width))
	mesh.surface_end()

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func append_point() -> void:
	_points.append(global_position)
	_widths.append([
		global_basis.x * _from_width,
		global_basis.x * _from_width - global_basis.x * _to_width])
	_lifespans.append(0.0)

func remove_point(i: int) -> void:
	_points.remove_at(i)
	_widths.remove_at(i)
	_lifespans.remove_at(i)
