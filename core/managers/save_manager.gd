extends Node

const SAVE_PATH := "C:/AboutStudy/GdProjects/black-white-dot-0604/save/save_data.json"

func save_data(key: String, value: Variant) -> void:
	var data := _load_all()
	data[key] = value
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_data(key: String, default: Variant = null) -> Variant:
	var data := _load_all()
	return data.get(key, default)

func _load_all() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		return {}
	return json.data as Dictionary
