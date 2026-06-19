extends PopupPanel
class_name OnlineMenu

signal host_requested(user_name: String, port: int)
signal join_requested(user_name: String, ip: String, port: int)

@onready var ip_address: OptionButton = $VBoxContainer/IpAddress
@onready var host_btn: Button = $VBoxContainer/HostBtn
@onready var join_btn: Button = $VBoxContainer/JoinBtn

var _user_name: String = ""

func _ready() -> void:
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	NetManager.host_discovered.connect(_on_host_discovered)
	ip_address.get_popup().about_to_popup.connect(_on_ip_button_opened)

func _on_ip_button_opened() -> void:
	_refresh_hosts()

func _on_host_pressed() -> void:
	var player_name := _get_user_name()
	host_requested.emit(player_name, GlobalCfg.game_port)

func _on_join_pressed() -> void:
	var player_name := _get_user_name()
	if ip_address.item_count == 0:
		return
	var selected_id: int = ip_address.get_selected_id()
	var host_info: Dictionary = ip_address.get_item_metadata(selected_id)
	var ip: String = host_info.get("ip", "127.0.0.1")
	var port: int = host_info.get("game_port", GlobalCfg.game_port)
	join_requested.emit(player_name, ip, port)

func _refresh_hosts() -> void:
	ip_address.clear()
	ip_address.add_item("搜索中...", 0)
	ip_address.set_item_disabled(0, true)
	NetManager.start_listen()

func _on_host_discovered(host_info: Dictionary) -> void:
	# 移除"搜索中..."提示
	if ip_address.get_item_count() > 0 and ip_address.get_item_text(0) == "搜索中...":
		ip_address.remove_item(0)
	# 添加新发现的主机
	var display_text: String = "%s:%s" % [host_info.get("host_name"), host_info.get("ip")]
	var id: int = ip_address.item_count
	ip_address.add_item(display_text, id)
	ip_address.set_item_metadata(id, host_info)
	ip_address.set_item_disabled(id, false)
	# 自动选择第一个主机
	if ip_address.item_count > 0:
		ip_address.select(0)

func _get_user_name() -> String:
	var player_name := _user_name.strip_edges().replace("\n", "").replace("\r", "")
	if player_name.is_empty():
		player_name = "玩家"
	return player_name

func sync_user_name(source_text: String) -> void:
	_user_name = source_text
