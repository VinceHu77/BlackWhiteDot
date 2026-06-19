extends ModeCfgRes
class_name WuziqiEatCfg

@export var board_size: int = 15
@export var cell_size: int = 55
@export var win_count: int = 5
@export var line_width: int = 5
@export var max_pieces: int = 50

@export var black_chess_scene: PackedScene
@export var white_chess_scene: PackedScene

enum GameState {
	MENU = 0,
	PLAYING = 1,
	PAUSED = 2,
	GAME_OVER = 3
}
const GAME_STATE_NAMES := {
	GameState.MENU: "主菜单",
	GameState.PLAYING: "对局中",
	GameState.PAUSED: "暂停",
	GameState.GAME_OVER: "游戏结束"
}

enum Player {
	NONE = 0,
	BLACK = 1,
	WHITE = 2
}
const PLAYER_NAMES := {
	Player.NONE: "无",
	Player.BLACK: "黑棋",
	Player.WHITE: "白棋"
}
