extends Node
class_name WuziqiEatRule

signal move_valid(pos: Vector2i)
signal move_invalid(reason: String)

var board_data: WuziqiEatData = null

func _init(data: WuziqiEatData) -> void:
	board_data = data

func check_move(x: int, y: int) -> bool:
	if not WuziqiEatUtil.is_valid_pos(x, y, board_data.config.board_size):
		move_invalid.emit("位置超出棋盘范围")
		return false
	if not board_data.is_empty(x, y):
		move_invalid.emit("该位置已有棋子")
		return false
	move_valid.emit(Vector2i(x, y))
	return true
