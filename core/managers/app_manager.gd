extends Node

var current_mode_id: String = ""
var current_mode: Node = null

func _ready() -> void:
	GlobalBus.mode_switch_requested.connect(_on_mode_switch_requested)

func _on_mode_switch_requested(mode_id: String) -> void:
	switch_to_mode(mode_id)

func switch_to_mode(mode_id: String) -> void:
	_unload_current_mode()
	var mode_scene_path: String
	match mode_id:
		"wuziqi":
			mode_scene_path = "res://games/wuziqi/view/wuziqi.tscn"
		"wuziqi_eat":
			mode_scene_path = "res://games/wuziqi_eat/view/wuziqi_eat.tscn"
		"snake":
			mode_scene_path = "res://games/snake/snake.tscn"
		_:
			mode_scene_path = "res://games/%s/view/ui/%s.tscn" % [mode_id, mode_id]
	if not ResourceLoader.exists(mode_scene_path): 
		printerr("AppManager: 找不到玩法场景: ", mode_scene_path)
		return
	_load_new_mode(mode_id, mode_scene_path)

func _unload_current_mode():
	if not current_mode:
		return
	if current_mode.has_method("destroy"):
		current_mode.destroy()
	current_mode.queue_free()
	current_mode = null
	GlobalBus.mode_unloaded.emit(current_mode_id)

func _load_new_mode(mode_id: String, scene_path: String) -> void:
	var scene := load(scene_path) as PackedScene
	current_mode = scene.instantiate()
	get_tree().root.add_child(current_mode)
	if current_mode.has_method("setup"):
		current_mode.setup()
	current_mode_id = mode_id
	GlobalBus.mode_loaded.emit(mode_id)
