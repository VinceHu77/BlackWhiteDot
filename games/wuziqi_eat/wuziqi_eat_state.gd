extends Node
class_name WuziqiEatState

var config: WuziqiEatCfg
var current_state: int
var current_player: int
var winner: int
var cur_round: int
var black_pieces: int
var white_pieces: int

func _init(cfg: WuziqiEatCfg) -> void:
	config = cfg
	current_state = WuziqiEatCfg.GameState.MENU
	current_player = WuziqiEatCfg.Player.BLACK
	winner = WuziqiEatCfg.Player.NONE
	cur_round = 0
	black_pieces = cfg.max_pieces
	white_pieces = cfg.max_pieces

func reset_state() -> void:
	current_state = WuziqiEatCfg.GameState.PLAYING
	current_player = WuziqiEatCfg.Player.BLACK
	winner = WuziqiEatCfg.Player.NONE
	cur_round = 0
	black_pieces = config.max_pieces
	white_pieces = config.max_pieces

func set_game_over(winning_player: int) -> void:
	current_state = WuziqiEatCfg.GameState.GAME_OVER
	winner = winning_player

func switch_player() -> void:
	current_player = WuziqiEatCfg.Player.WHITE if current_player == WuziqiEatCfg.Player.BLACK else WuziqiEatCfg.Player.BLACK

func is_playing() -> bool:
	return current_state == WuziqiEatCfg.GameState.PLAYING

func is_my_turn() -> bool:
	# 双人模式：游戏发起者是黑棋先手
	var my_color := WuziqiEatCfg.Player.BLACK if NetManager.is_game_host else WuziqiEatCfg.Player.WHITE
	return current_player == my_color

func end_turn() -> void:
	cur_round += 1

func use_piece(color: int) -> bool:
	if color == WuziqiEatCfg.Player.BLACK:
		if black_pieces <= 0:
			return false
		black_pieces -= 1
		return true
	elif color == WuziqiEatCfg.Player.WHITE:
		if white_pieces <= 0:
			return false
		white_pieces -= 1
		return true
	return false

func get_piece_count(color: int) -> int:
	if color == WuziqiEatCfg.Player.BLACK:
		return black_pieces
	elif color == WuziqiEatCfg.Player.WHITE:
		return white_pieces
	return 0
