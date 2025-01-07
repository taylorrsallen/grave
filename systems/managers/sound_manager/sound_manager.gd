extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
enum BackgroundTrackLayer {
	AMBIENCE_0,
	AMBIENCE_1,
	AMBIENCE_2,
	AMBIENCE_3,
	AMBIENCE_4,
	AMBIENCE_5,
	MUSIC_0,
	MUSIC_1,
	MUSIC_2,
}

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
const MAX_BACKGROUND_TRACKS: int = 16
const AUDIO_BUSES: Array[String] = [
	"Master",
]

const SOUND_DATABASE: SoundDatabase = preload("res://resources/sounds/sound_database.res")

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var background_tracks: Array[BackgroundTrack] = []
@export var background_track_fades: Array[BackgroundTrackFade]

var max_sounds: int = 64
var current_sounds: int

@export var master_volume: float = 1.0
@export var music_volume: float = 0.9
@export var ambience_volume: float = 1.0
@export var ui_volume: float = 1.0
@export var sfx_volume: float = 1.0

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _enter_tree() -> void: for _i in MAX_BACKGROUND_TRACKS: background_tracks.append(null)

func _physics_process(delta: float) -> void:
	var fades_to_erase: Array[BackgroundTrackFade] = []
	for background_track_fade in background_track_fades:
		if background_track_fade.try_finish(delta): fades_to_erase.append(background_track_fade)
	for fade_to_erase in fades_to_erase: background_track_fades.erase(fade_to_erase)
	
	for background_track in background_tracks:
		if !background_track: continue
		background_track.volume_db = background_track.base_volume_db - (50.0 - 50.0 * master_volume * music_volume)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func play_ui_sfx(id: int, type: SoundDatabase.SoundType, volume_db: float = 0.0, pitch: float = 1.0, bus: int = 0) -> void:
	_play_ui_sfx(SOUND_DATABASE.get_sound(id, type), volume_db, pitch, bus)

func play_pitched_ui_sfx(id: int, type: SoundDatabase.SoundType, pitch_min: float = 0.9, pitch_max: float = 1.1, volume_db: float = 0.0, bus: int = 0) -> void:
	_play_pitched_ui_sfx(SOUND_DATABASE.get_sound(id, type), pitch_min, pitch_max, volume_db, bus)

func _play_ui_sfx(stream: AudioStream, volume_db: float, pitch: float, bus: int) -> void:
	if current_sounds >= max_sounds: return
	
	var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	stream_player.stream = stream
	stream_player.volume_db = volume_db - (50.0 - 50.0 * master_volume * ui_volume)
	stream_player.pitch_scale = pitch
	stream_player.bus = AUDIO_BUSES[bus]
	stream_player.finished.connect(stream_player.queue_free)
	stream_player.finished.connect(_on_sound_finished)
	
	add_child(stream_player)
	stream_player.play()
	current_sounds += 1

func _play_pitched_ui_sfx(stream: AudioStream, pitch_min: float, pitch_max: float, volume_db: float, bus: int) -> void:
	_play_ui_sfx(stream, volume_db, randf_range(pitch_min, pitch_max), bus)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func play_3d_sfx(id: int, type: SoundDatabase.SoundType, position: Vector3, volume_db: float = 0.0, unit_size: float = 10.0, pitch: float = 1.0, bus: int = 0) -> void:
	_play_3d_sfx(SOUND_DATABASE.get_sound(id, type), position, volume_db, unit_size, pitch, bus)

func play_pitched_3d_sfx(id: int, type: SoundDatabase.SoundType, position: Vector3, pitch_min: float = 0.9, pitch_max: float = 1.1, volume_db: float = 0.0, unit_size: float = 5.0, bus: int = 0) -> void:
	_rpc_play_pitched_3d_sfx.rpc(id, type, position, pitch_min, pitch_max, volume_db, unit_size, bus)

@rpc("any_peer", "call_local", "unreliable")
func _rpc_play_pitched_3d_sfx(id: int, type: SoundDatabase.SoundType, position: Vector3, pitch_min: float = 0.9, pitch_max: float = 1.1, volume_db: float = 0.0, unit_size: float = 5.0, bus: int = 0) -> void:
	_play_pitched_3d_sfx(SOUND_DATABASE.get_sound(id, type), position, pitch_min, pitch_max, volume_db, unit_size, bus)

func _play_3d_sfx(stream: AudioStream, position: Vector3, volume_db: float, unit_size: float, pitch: float, bus: int) -> void:
	if current_sounds >= max_sounds: return
	
	var stream_player_3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	stream_player_3d.stream = stream
	stream_player_3d.position = position
	stream_player_3d.volume_db = volume_db - (50.0 - 50.0 * master_volume * sfx_volume)
	stream_player_3d.unit_size = unit_size
	stream_player_3d.pitch_scale = pitch
	stream_player_3d.bus = AUDIO_BUSES[bus]
	stream_player_3d.finished.connect(stream_player_3d.queue_free)
	stream_player_3d.finished.connect(_on_sound_finished)
	
	add_child(stream_player_3d)
	stream_player_3d.play()
	current_sounds += 1

func _play_pitched_3d_sfx(stream: AudioStream, position: Vector3, pitch_min: float, pitch_max: float, volume_db: float, unit_size: float, bus: int) -> void:
	_play_3d_sfx(stream, position, volume_db, unit_size, randf_range(pitch_min, pitch_max), bus)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func play_background_track(id: int, type: SoundDatabase.SoundType, layer: int, loop: bool = true, base_volume_db: float = 0.0, pitch: float = 1.0, bus: int = 0) -> void:
	var effective_volume_db: float = base_volume_db
	if type == SoundDatabase.SoundType.BGT_MUSIC:
		effective_volume_db -= 50.0 - 50.0 * master_volume * music_volume
	else:
		effective_volume_db -= 50.0 - 50.0 * master_volume * ambience_volume
	_play_background_track(SOUND_DATABASE.get_sound(id, type), layer, loop, base_volume_db, effective_volume_db, pitch, bus)

func _play_background_track(stream: AudioStream, layer: int, loop: bool, base_volume_db: float, effective_volume_db: float, pitch: float, bus: int) -> void:
	if layer >= MAX_BACKGROUND_TRACKS: return
	
	var background_track: BackgroundTrack = BackgroundTrack.new()
	background_track.layer = layer
	background_track.stream = stream
	background_track.stream["loop"] = loop
	background_track.base_volume_db = base_volume_db
	background_track.volume_db = effective_volume_db
	background_track.pitch_scale = pitch
	background_track.bus = AUDIO_BUSES[bus]
	
	set_background_track(background_track, layer)
	
	add_child(background_track)
	background_track.play()

func get_background_track(layer: int) -> BackgroundTrack:
	return background_tracks[layer]

func set_background_track(background_track: BackgroundTrack, layer: int) -> void:
	if layer >= MAX_BACKGROUND_TRACKS: return
	if background_tracks[layer]: background_tracks[layer].queue_free()
	background_tracks[layer] = background_track

func erase_background_track(layer: int) -> void:
	if layer >= MAX_BACKGROUND_TRACKS: return
	if background_tracks[layer]: background_tracks[layer].queue_free()
	background_tracks[layer] = null

func pause_background_track(layer: int) -> void:
	if layer >= MAX_BACKGROUND_TRACKS: return
	if background_tracks[layer]: background_tracks[layer].stop()

func unpause_background_track(layer: int) -> void:
	if layer >= MAX_BACKGROUND_TRACKS: return
	if background_tracks[layer]: background_tracks[layer].play()

func fade_background_track(layer: int, fade_time: float = 5.0, start_db: float = 31.0, target_db: float = -40.0, erase_when_complete: bool = false) -> void:
	if !background_tracks[layer]: return
	var fade: BackgroundTrackFade = BackgroundTrackFade.new()
	fade.bgt_layer = layer
	fade.fade_time = fade_time
	fade.start_db = background_tracks[layer].base_volume_db if start_db > 30.0 else start_db
	fade.target_db = clampf(target_db, -999.9, 30.0)
	fade.erase_when_complete = erase_when_complete
	background_track_fades.append(fade)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func _on_sound_finished() -> void: current_sounds -= 1
