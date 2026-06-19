extends Node

var master_volume := 1.0:
	set(v):
		master_volume = v
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(v))

var sfx_volume := 1.0:
	set(v):
		sfx_volume = v
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))

var music_volume := 1.0:
	set(v):
		music_volume = v
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))

func play_sfx(resource: AudioStream, pitch_range := Vector2(1.0, 1.0)) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = resource
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	player.finished.connect(player.queue_free)
	player.play()

func play_music(resource: AudioStream) -> void:
	for child in get_children():
		if child is AudioStreamPlayer and child.name == "MusicPlayer":
			child.stream = resource
			child.play()
			return

	var player := AudioStreamPlayer.new()
	player.name = "MusicPlayer"
	add_child(player)
	player.stream = resource
	player.play()
