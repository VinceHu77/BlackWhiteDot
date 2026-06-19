extends BaseModeEntry
class_name WuziqiEat

@onready var wuziqi_eat_board: WuziqiEatBoard = $WuziqiEatBoard
@onready var wuziqi_eat_hud: WuziqiEatHUD = $WuziqiEatHUD
@onready var online_hud: OnlineHUD = $OnlineHUD
@onready var black_piece_ctn: WuziqiEatPieceCtn = $BlackCtn/PieceCtn
@onready var white_piece_ctn: WuziqiEatPieceCtn = $WhiteCtn/PieceCtn

var config: WuziqiEatCfg
var mode_bus: WuziqiEatBus = WuziqiEatBus.new()
var game_flow: WuziqiEatFlow

func setup() -> void:
	await get_tree().process_frame
	config = load("res://games/wuziqi_eat/wuziqi_eat_default.tres")
	game_flow = WuziqiEatFlow.new(config, mode_bus)
	add_child(mode_bus)
	wuziqi_eat_board.init_board(config, game_flow)
	wuziqi_eat_hud.bind(game_flow)
	game_flow.bind(wuziqi_eat_board, wuziqi_eat_hud)
	black_piece_ctn.init_container(config.black_chess_scene)
	white_piece_ctn.init_container(config.white_chess_scene)
	_connect_signals()
	_setup_online()

func destroy() -> void:
	_disconnect_signals()
	if game_flow and game_flow.chess_board:
		game_flow.chess_board.reset_board()

func _setup_online() -> void:
	if NetManager.is_game_host:
		online_hud.set_black_seat(NetManager.my_name)
		online_hud.set_white_seat(NetManager.opponent_name)
	else:
		online_hud.set_black_seat(NetManager.opponent_name)
		online_hud.set_white_seat(NetManager.my_name)
	wuziqi_eat_board.visible = true
	wuziqi_eat_hud.visible = true
	game_flow.start_new_game()

func _connect_signals() -> void:
	# 网络信号
	if not NetManager.board_set.is_connected(_on_remote_board_set):
		NetManager.board_set.connect(_on_remote_board_set)
	if not NetManager.restart_requested.is_connected(_on_remote_restart):
		NetManager.restart_requested.connect(_on_remote_restart)
	# 事件总线信号
	mode_bus.piece_placed.connect(_on_mode_piece_placed)
	mode_bus.mode_back_to_menu.connect(_on_back_to_menu)

func _disconnect_signals() -> void:
	# 网络信号
	if NetManager.board_set.is_connected(_on_remote_board_set):
		NetManager.board_set.disconnect(_on_remote_board_set)
	if NetManager.restart_requested.is_connected(_on_remote_restart):
		NetManager.restart_requested.disconnect(_on_remote_restart)
	# 总线信号
	if mode_bus:
		if mode_bus.piece_placed.is_connected(_on_mode_piece_placed):
			mode_bus.piece_placed.disconnect(_on_mode_piece_placed)
		if mode_bus.mode_back_to_menu.is_connected(_on_back_to_menu):
			mode_bus.mode_back_to_menu.disconnect(_on_back_to_menu)

func _on_back_to_menu() -> void:
	mode_finished.emit(config.mode_id)

func _on_mode_piece_placed(color: int) -> void:
	if color == WuziqiEatCfg.Player.BLACK and black_piece_ctn is WuziqiEatPieceCtn:
		black_piece_ctn.remove_piece()
	elif color == WuziqiEatCfg.Player.WHITE and white_piece_ctn is WuziqiEatPieceCtn:
		white_piece_ctn.remove_piece()

func _on_remote_board_set(x: int, y: int, color: int) -> void:
	if game_flow and game_flow.chess_board:
		game_flow.chess_board.set_board(x, y, color)

func _on_remote_restart() -> void:
	if game_flow:
		game_flow.start_new_game()
