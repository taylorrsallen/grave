extends AudioStreamPlayer
class_name BackgroundTrack

var layer: int
var base_volume_db: float

func _on_finished() -> void:
	get_parent().background_tracks[layer] = null
	queue_free()
