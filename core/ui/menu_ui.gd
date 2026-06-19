extends Control
class_name MenuUI

@onready var connect_btn: Button = $StatusBar/ConnectBtn
@onready var user_name: TextEdit = $StatusBar/UserName
@onready var status_label: Label = $StatusBar/StatusLabel
@onready var quit_btn: Button = $StatusBar/QuitBtn
@onready var online_menu: OnlineMenu = $"../OnlineMenu"
@onready var invite_dialog: InviteDialog = $"../InviteDialog"

## 支持的游戏按钮列表（按钮名 → mode_id）
const GAME_BUTTONS := {
	"Wuziqi": "wuziqi",
	"WuziqiEat": "wuziqi_eat",
	"Snake": "snake"
}

var _my_name: String = ""

func _ready() -> void:
	# 主菜单按钮
	connect_btn.pressed.connect(_on_connect_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	for child in $GridContainer.get_children():
		if child is Button and child.name in GAME_BUTTONS:
			child.pressed.connect(_on_game_selected.bind(GAME_BUTTONS[child.name]))
	# 更新按钮文本，显示游玩次数
	_update_game_button_texts()
	# 监听模式加载信号，以便更新次数显示
	GlobalBus.mode_loaded.connect(_on_mode_loaded)
	# 联机菜单信号
	online_menu.visible = false
	online_menu.host_requested.connect(_on_host_requested)
	online_menu.join_requested.connect(_on_join_requested)
	# 邀请弹窗信号
	invite_dialog.accepted.connect(_on_invite_accepted)
	invite_dialog.declined.connect(_on_invite_declined)
	# 网络信号
	NetManager.peer_connected.connect(_on_peer_connected)
	NetManager.opponent_name_received.connect(_on_opponent_name_received)
	NetManager.game_invite_received.connect(_on_game_invite_received)
	NetManager.game_invite_accepted.connect(_on_game_invite_accepted)
	NetManager.game_invite_declined.connect(_on_game_invite_declined)

# ========== 主菜单按钮 ==========
func _on_connect_pressed() -> void:
	if NetManager.connected:
		status_label.text = "已连接到 %s" % NetManager.opponent_name
		return
	# 同步用户名到 online_menu
	online_menu.sync_user_name(user_name.text)
	online_menu.visible = true

func _on_quit_pressed() -> void:
	if NetManager.connected:
		NetManager.disconnect_peer()
	get_tree().quit()

# ========== 联机菜单 ==========
func _on_host_requested(_user_name: String, port: int) -> void:
	_my_name = _user_name
	NetManager.my_name = _user_name
	if not NetManager.host_game(port):
		printerr("host_game failed")
		return
	NetManager.is_server = true
	online_menu.visible = false
	status_label.text = "等待好友中..."

func _on_join_requested(_user_name: String, ip: String, port: int) -> void:
	_my_name = _user_name
	NetManager.my_name = _user_name
	if not NetManager.join_game(ip, port):
		printerr("join_game failed")
		return
	NetManager.is_server = false
	online_menu.visible = false
	# 客户端连接后立即发送自己的名字
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		NetManager.exchange_name.rpc(_my_name)

# TODO: 取消联机
func _on_online_back() -> void:
	online_menu.visible = false
	if NetManager.connected:
		NetManager.disconnect_peer()
		status_label.text = ""

# ========== 网络事件 ==========
func _on_peer_connected(_id: int) -> void:
	# 服务端：有人连入时，向对方发送自己的名字
	NetManager.exchange_name.rpc(_my_name)

func _on_opponent_name_received(opponent_name: String) -> void:
	NetManager.opponent_name = opponent_name
	NetManager.connected = true
	status_label.text = "好友: %s" % opponent_name

# ========== 游戏选择 ==========
func _on_game_selected(game_id: String) -> void:
	if NetManager.connected:
		# 联机模式：向对方发送邀请，发起者标记为游戏主机（先手）
		NetManager.is_game_host = true
		status_label.text = "已向 %s 发出 %s 邀请..." % [NetManager.opponent_name, get_display_name(game_id)]
		NetManager.request_game.rpc(game_id)
	else:
		#status_label.text = "请先与好友联机"
		#_enter_game(game_id)
		get_tree().change_scene_to_file("res://games/snake/snake.tscn")

# ========== 游戏邀请 ==========
func _on_game_invite_received(game_id: String, from_name: String) -> void:
	# 收到邀请，标记为非游戏发起者（后手）
	NetManager.is_game_host = false
	invite_dialog.show_invite(game_id, from_name)

func _on_invite_accepted(game_id: String) -> void:
	NetManager.accept_game.rpc(game_id)
	_enter_game(game_id)

func _on_game_invite_accepted(game_id: String) -> void:
	status_label.text = "%s 接受了邀请！" % NetManager.opponent_name
	_enter_game(game_id)

func _on_invite_declined() -> void:
	NetManager.decline_game.rpc()

func _on_game_invite_declined() -> void:
	status_label.text = "%s 拒绝了邀请" % NetManager.opponent_name

func _enter_game(game_id: String) -> void:
	GlobalBus.mode_switch_requested.emit(game_id)

func get_display_name(game_id: String) -> String:
	match game_id:
		"wuziqi":
			return "五子棋"
		"wuziqi_eat":
			return "吃子补子"
		"snake":
			return "贪吃蛇"
		_:
			return game_id

func _update_game_button_texts() -> void:
	for child in $GridContainer.get_children():
		if child is Button and child.name in GAME_BUTTONS:
			var mode_id: String = GAME_BUTTONS[child.name]
			var count: int = StatsManager.get_mode_open_count(mode_id)
			var display_name: String = get_display_name(mode_id)
			child.text = "%s (%d)" % [display_name, count]

func _on_mode_loaded(_mode_id: String) -> void:
	_update_game_button_texts()

func get_user_name() -> String:
	return user_name.strip_edges() if not user_name.is_empty() else "玩家"
