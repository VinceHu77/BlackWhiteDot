extends Control
class_name WuziqiEatHUD

signal restart_clicked()
signal back_to_menu_clicked()

@onready var turn_lbl: Label = $TurnLbl
@onready var result_pan: Panel = $ResultPan
@onready var result_lbl: Label = $ResultPan/ResultLbl
@onready var restart_btn: Button = $ResultPan/RestartBtn
@onready var back_btn: Button = $ResultPan/BackBtn

var game_flow: WuziqiEatFlow

func _ready() -> void:
	result_pan.visible = false
	restart_btn.pressed.connect(_on_restart_clicked)
	back_btn.pressed.connect(_on_back_to_menu_clicked)
	
func bind(flow: WuziqiEatFlow) -> void:
	game_flow = flow

func _on_restart_clicked() -> void:
	restart_clicked.emit()

func _on_back_to_menu_clicked() -> void:
	back_to_menu_clicked.emit()

func update_turn(player: int) -> void:
	var player_name = WuziqiEatCfg.PLAYER_NAMES[player]
	turn_lbl.text = "%s 回合" % player_name

func show_result(winner: int) -> void:
	var player_name = WuziqiEatCfg.PLAYER_NAMES[winner]
	result_lbl.text = "%s 胜利！" % player_name
	result_pan.visible = true

func hide_result() -> void:
	result_pan.visible = false

func show_hint(message: String) -> void:
	turn_lbl.text = message
	await get_tree().create_timer(1.0).timeout
	if game_flow:
		update_turn(game_flow.get_game_state().current_player)
