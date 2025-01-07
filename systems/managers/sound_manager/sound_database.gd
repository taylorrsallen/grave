extends Resource
class_name SoundDatabase

enum SoundType {
	SFX_UI,
	SFX_EXPLOSION,
	SFX_FOOTSTEP,
	SFX_FOLEY,
	SFX_VOICE,
	BGT_WIND,
	BGT_DRONES,
	BGT_MUSIC,
}

@export var ui: Array[AudioStream]
@export var explosion: Array[AudioStream]
@export var footstep: Array[AudioStream]
@export var foley: Array[AudioStream]
@export var voice: Array[AudioStream]

@export var wind: Array[AudioStream]
@export var drones: Array[AudioStream]
@export var music: Array[AudioStream]

func get_sound(sound: int, sound_type: int) -> AudioStream:
	match sound_type:
		SoundType.SFX_UI: return ui[sound]
		SoundType.SFX_EXPLOSION: return explosion[sound]
		SoundType.SFX_FOOTSTEP: return footstep[sound]
		SoundType.SFX_FOLEY: return foley[sound]
		SoundType.SFX_VOICE: return voice[sound]
		SoundType.BGT_WIND: return wind[sound]
		SoundType.BGT_DRONES: return drones[sound]
		SoundType.BGT_MUSIC: return music[sound]
		_: return null
