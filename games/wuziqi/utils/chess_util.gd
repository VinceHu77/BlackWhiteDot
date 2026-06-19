extends Node
class_name ChessUtil

const DIRECTIONS = [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(1, 1),
	Vector2(1, -1)
]

static func is_valid_pos(x: int, y: int, board_size: int) -> bool:
	return x >= 0 and x < board_size and y >= 0 and y < board_size

static func check_win_normal(board: Array, x: int, y: int, win_count: int) -> int:
	var color = board[y][x]
	if color == WuziqiCfg.Player.NONE:
		return WuziqiCfg.Player.NONE
	for dir in DIRECTIONS:
		var count := 1 + _count_dir(board, x, y, dir, color) + _count_dir(board, x, y, -dir, color)
		if count >= win_count:
			return color
	return WuziqiCfg.Player.NONE

static func _count_dir(board: Array, x: int, y: int, dir: Vector2, color: int) -> int:
	var count := 0
	var nx := x + int(dir.x)
	var ny := y + int(dir.y)
	var board_size := board.size()
	while is_valid_pos(nx, ny, board_size) and board[ny][nx] == color:
		count += 1
		nx += int(dir.x)
		ny += int(dir.y)
	return count

static func get_click_position(event_pos: Vector2, cell_size: float, grid_offset: Vector2 = Vector2.ZERO) -> Vector2i:
	var x := int((event_pos.x - grid_offset.x + cell_size / 2.0) / cell_size)
	var y := int((event_pos.y - grid_offset.y + cell_size / 2.0) / cell_size)
	return Vector2i(x, y)

static func get_opponent(color: int) -> int:
	if color == WuziqiCfg.Player.BLACK:
		return WuziqiCfg.Player.WHITE
	elif color == WuziqiCfg.Player.WHITE:
		return WuziqiCfg.Player.BLACK
	return WuziqiCfg.Player.NONE
