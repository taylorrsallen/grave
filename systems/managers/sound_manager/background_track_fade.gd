class_name BackgroundTrackFade extends Resource

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
@export var bgt_layer: int
@export var fade_time: float = 1.0
@export var start_db: float
@export var target_db: float = -40.0
var lifetime: float

@export var erase_when_complete: bool

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func try_finish(delta: float) -> bool:
	if !SoundManager.background_tracks[bgt_layer]: return true
	
	lifetime += delta
	if lifetime < fade_time:
		var fade_percent: float = lifetime / fade_time
		SoundManager.background_tracks[bgt_layer].base_volume_db = lerpf(start_db, target_db, fade_percent)
	else:
		SoundManager.background_tracks[bgt_layer].base_volume_db = target_db
		if erase_when_complete: SoundManager.erase_background_track(bgt_layer)
		return true
	return false
