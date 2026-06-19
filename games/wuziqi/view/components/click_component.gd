extends Control
class_name ClickComp

signal cell_clicked(pos: Vector2i)

var cell_size: int = 70

func set_config(cfg: WuziqiCfg) -> void:
	cell_size = cfg.cell_size

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var local_pos := get_local_mouse_position()
		var grid_pos := ChessUtil.get_click_position(local_pos, cell_size)
		cell_clicked.emit(grid_pos)
