extends Node
class_name WuziqiFlow

signal state_changed(state: int)

var config: WuziqiCfg
var game_state: WuziqiState
var chess_board: WuziqiChessBoard = null
var game_hud: GameHUD = null
var mode_bus: WuziqiModeBus = null

func _init(cfg: WuziqiCfg, bus: WuziqiModeBus = null) -> void:
	config = cfg
	game_state = WuziqiState.new(cfg)
	mode_bus = bus

func bind(board: WuziqiChessBoard, hud: GameHUD) -> void:
	chess_board = board
	game_hud = hud
	chess_board.piece_placed.connect(_on_piece_placed)
	chess_board.game_over.connect(_on_game_over)
	chess_board.invalid_move.connect(_on_invalid_move)
	game_hud.restart_clicked.connect(_on_restart)
	game_hud.back_to_menu_clicked.connect(_on_back_to_menu)

func start_new_game() -> void:
	game_state.reset_state()
	chess_board.reset_board()
	game_hud.hide_result()
	_update_hud()
	state_changed.emit(game_state.current_state)

func _on_piece_placed(pos: Vector2i, color: int) -> void:
	game_state.switch_player()
	_update_hud()
	if mode_bus:
		mode_bus.piece_placed.emit(pos, color)
		mode_bus.turn_changed.emit(game_state.current_player)
		mode_bus.piece_count_changed.emit(color, game_state.get_piece_count(color))

func _on_game_over(winner: int) -> void:
	game_state.set_game_over(winner)
	game_hud.show_result(winner)
	state_changed.emit(game_state.current_state)
	if mode_bus:
		mode_bus.game_ended.emit(winner)

func _on_invalid_move(reason: String) -> void:
	game_hud.show_hint(reason)

func _on_restart() -> void:
	NetManager.restart_game.rpc()

func _on_back_to_menu() -> void:
	game_state.current_state = WuziqiCfg.GameState.MENU
	if mode_bus:
		mode_bus.mode_back_to_menu.emit()

func _update_hud() -> void:
	if game_hud:
		game_hud.update_turn(game_state.current_player)

func get_game_state() -> WuziqiState:
	return game_state
