extends Node
class_name WuziqiBoardData

var config: WuziqiCfg
var grid: Array = []

func _init(cfg: WuziqiCfg) -> void:
	config = cfg
	clear_grid()

func clear_grid() -> void:
	grid.clear()
	for i in range(config.board_size):
		grid.append([])
		for j in range(config.board_size):
			grid[i].append(0)

func is_empty(x: int, y: int) -> bool:
	return ChessUtil.is_valid_pos(x, y, config.board_size) and grid[y][x] == 0

func set_cell(x: int, y: int, color: int) -> bool:
	if not is_empty(x, y):
		return false
	grid[y][x] = color
	return true

func clear_cell(x: int, y: int) -> void:
	if ChessUtil.is_valid_pos(x, y, config.board_size):
		grid[y][x] = 0

func get_cell(x: int, y: int) -> int:
	if not ChessUtil.is_valid_pos(x, y, config.board_size):
		return 0
	return grid[y][x]

func check_win(x: int, y: int) -> int:
	return ChessUtil.check_win_normal(grid, x, y, config.win_count)
