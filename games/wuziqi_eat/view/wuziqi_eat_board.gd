extends Control
class_name WuziqiEatBoard

signal piece_placed(pos: Vector2i, color: int)
signal game_over(winner: int)
signal invalid_move(reason: String)

@onready var wuziqi_eat_click: WuziqiEatClick = $WuziqiEatClick
@onready var wuziqi_eat_draw: WuziqiEatDraw = $WuziqiEatDraw


var config: WuziqiEatCfg
var board_data: WuziqiEatData
var game_flow: WuziqiEatFlow
var rule_comp: WuziqiEatRule = null

func init_board(cfg: WuziqiEatCfg, flow: WuziqiEatFlow) -> void:
	config = cfg
	game_flow = flow
	board_data = WuziqiEatData.new(cfg)
	rule_comp = WuziqiEatRule.new(board_data)
	rule_comp.move_valid.connect(_on_move_valid)
	rule_comp.move_invalid.connect(_on_move_invalid)
	wuziqi_eat_click.cell_clicked.connect(_on_cell_clicked)
	wuziqi_eat_click.set_config(cfg)
	wuziqi_eat_draw.set_config(cfg)
	wuziqi_eat_draw.queue_redraw()

func _on_cell_clicked(pos: Vector2i) -> void:
	if not game_flow.get_game_state().is_playing():
		return
	if not game_flow.get_game_state().is_my_turn():
		return
	if WuziqiEatUtil.is_valid_pos(pos.x, pos.y, config.board_size):
		rule_comp.check_move(pos.x, pos.y)
	else:
		print("Invalid grid position")

func _on_move_valid(pos: Vector2i) -> void:
	var current_player := game_flow.get_game_state().current_player
	NetManager.set_board.rpc(pos.x, pos.y, current_player)

func _on_move_invalid(reason: String) -> void:
	invalid_move.emit(reason)

func reset_board() -> void:
	board_data.clear_grid()
	wuziqi_eat_draw.clear_pieces()

func set_board(x: int, y: int, color: int) -> void:
	if not board_data.is_empty(x, y):
		return
	if not game_flow.get_game_state().use_piece(color):
		invalid_move.emit("棋子已用完！")
		return
	board_data.set_cell(x, y, color)
	wuziqi_eat_draw.draw_piece(x, y, color)
	piece_placed.emit(Vector2i(x, y), color)
	var winner := board_data.check_win(x, y)
	if winner != WuziqiEatCfg.Player.NONE:
		game_over.emit(winner)
		return
	game_flow.get_game_state().end_turn()
