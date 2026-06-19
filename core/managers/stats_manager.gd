extends Node

const STATS_KEY := "game_stats"

var mode_play_counts: Dictionary = {}

func _ready() -> void:
	_load_stats()
	GlobalBus.mode_loaded.connect(_on_mode_loaded)

func _on_mode_loaded(mode_id: String) -> void:
	if mode_id not in mode_play_counts:
		mode_play_counts[mode_id] = 0
	mode_play_counts[mode_id] += 1
	_save_stats()

func get_mode_open_count(mode_id: String) -> int:
	return mode_play_counts.get(mode_id, 0)

#func get_total_open_count() -> int:
	#var total := 0
	#for count in mode_play_counts.values():
		#total += count
	#return total
#
#func get_all_stats() -> Dictionary:
	#return mode_play_counts.duplicate()
#
#func reset_stats() -> void:
	#mode_play_counts = {}
	#_save_stats()

func _load_stats() -> void:
	var data: Variant = SaveManager.load_data(STATS_KEY, {})
	if data is Dictionary:
		mode_play_counts = data
	else:
		mode_play_counts = {}

func _save_stats() -> void:
	SaveManager.save_data(STATS_KEY, mode_play_counts)
