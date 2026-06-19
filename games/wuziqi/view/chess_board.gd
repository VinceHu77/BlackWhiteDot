extends Control
class_name WuziqiChessBoard

signal piece_placed(pos: Vector2i, color: int)
signal game_over(winner: int)
signal invalid_move(reason: String)

@onready var click_comp: ClickComp = $ClickComp
@onready var draw_comp: DrawComp = $DrawComp

var config: WuziqiCfg
var board_data: WuziqiBoardData
var game_flow: WuziqiFlow
var rule_comp: RuleComp = null

func init_board(cfg: WuziqiCfg, flow: WuziqiFlow) -> void:
	config = cfg
	game_flow = flow
	board_data = WuziqiBoardData.new(cfg)
	rule_comp = RuleComp.new(board_data)
	rule_comp.move_valid.connect(_on_move_valid)
	rule_comp.move_invalid.connect(_on_move_invalid)
	click_comp.cell_clicked.connect(_on_cell_clicked)
	click_comp.set_config(cfg)
	draw_comp.set_config(cfg)
	draw_comp.queue_redraw()

func _on_cell_clicked(pos: Vector2i) -> void:
	if not game_flow.get_game_state().is_playing():
		return
	if not game_flow.get_game_state().is_my_turn(NetManager.all_peers, NetManager.uid):
		return
	if ChessUtil.is_valid_pos(pos.x, pos.y, config.board_size):
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
	draw_comp.clear_pieces()

func set_board(x: int, y: int, color: int) -> void:
	if not board_data.is_empty(x, y):
		return
	if not game_flow.get_game_state().use_piece(color):
		invalid_move.emit("棋子已用完！")
		return
	board_data.set_cell(x, y, color)
	draw_comp.draw_piece(x, y, color)
	piece_placed.emit(Vector2i(x, y), color)
	var winner := board_data.check_win(x, y)
	if winner != WuziqiCfg.Player.NONE:
		game_over.emit(winner)
		return
	game_flow.get_game_state().end_turn()
