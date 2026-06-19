extends BaseModeEntry
class_name WuziqiModeEntry

@onready var chess_board: WuziqiChessBoard = $ChessBoard
@onready var game_hud: GameHUD = $GameHUD
@onready var online_hud: OnlineHUD = $OnlineHUD

var config: WuziqiCfg
var game_flow: WuziqiFlow
var mode_bus: WuziqiModeBus

func setup(cfg: ModeCfgRes = null) -> void:
	await get_tree().process_frame
	mode_bus = WuziqiModeBus.new()
	add_child(mode_bus)
	if cfg and cfg is WuziqiCfg:
		config = cfg
	else:
		config = load("res://games/wuziqi/config/default_wuziqi.tres") as WuziqiCfg
	game_flow = WuziqiFlow.new(config, mode_bus)
	chess_board.init_board(config, game_flow)
	game_hud.bind(game_flow)
	game_flow.bind(chess_board, game_hud)
	_connect_network_signals()
	_connect_bus_signals()
	
	if NetManager.connected:
		_setup_online()

func destroy() -> void:
	_disconnect_network_signals()
	if game_flow and game_flow.chess_board:
		game_flow.chess_board.reset_board()

func _setup_online() -> void:
	if NetManager.is_game_host:
		online_hud.set_black_seat(NetManager.my_name)
		online_hud.set_white_seat(NetManager.opponent_name)
	else:
		online_hud.set_black_seat(NetManager.opponent_name)
		online_hud.set_white_seat(NetManager.my_name)
	
	chess_board.visible = true
	game_hud.visible = true
	game_flow.start_new_game()

func _connect_network_signals() -> void:
	if not NetManager.board_set.is_connected(_on_remote_board_set):
		NetManager.board_set.connect(_on_remote_board_set)
	if not NetManager.restart_requested.is_connected(_on_remote_restart):
		NetManager.restart_requested.connect(_on_remote_restart)

func _disconnect_network_signals() -> void:
	if NetManager.board_set.is_connected(_on_remote_board_set):
		NetManager.board_set.disconnect(_on_remote_board_set)
	if NetManager.restart_requested.is_connected(_on_remote_restart):
		NetManager.restart_requested.disconnect(_on_remote_restart)

func _connect_bus_signals() -> void:
	mode_bus.mode_back_to_menu.connect(_on_back_to_menu)

func _on_back_to_menu() -> void:
	mode_finished.emit(config.mode_id)


func _on_remote_board_set(x: int, y: int, color: int) -> void:
	if game_flow and game_flow.chess_board:
		game_flow.chess_board.set_board(x, y, color)

func _on_remote_restart() -> void:
	if game_flow:
		game_flow.start_new_game()
