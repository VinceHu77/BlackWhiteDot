extends Node

var peer := ENetMultiplayerPeer.new()
var uid: int = 0
var all_peers: Array[int] = [1]
var is_server: bool = false
var connected: bool = false
var is_game_host: bool = false  # 是否是游戏发起者（邀请者），发起者先手
var my_name: String = ""
var opponent_name: String = ""

# UDP 广播/监听
var broadcast_socket: PacketPeerUDP = null
var listen_socket: PacketPeerUDP = null
var broadcast_timer: Timer = null
var discovered_hosts: Array[Dictionary] = []

signal peer_connected(id: int)
signal player_name_received(player_name: String, is_white: bool)
signal board_set(x: int, y: int, color: int)
signal restart_requested()
signal opponent_name_received(opponent_name: String)
signal game_invite_received(game_id: String, from_name: String)
signal game_invite_accepted(game_id: String)
signal game_invite_declined()
signal host_discovered(host_info: Dictionary)

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)

func _process(_delta: float) -> void:
	# 监听广播消息
	if listen_socket and listen_socket.is_bound():
		while listen_socket.get_available_packet_count() > 0:
			var packet: PackedByteArray = listen_socket.get_packet()
			if packet.size() > 0:
				var msg: String = packet.get_string_from_utf8()
				var host_ip: String = listen_socket.get_packet_ip()
				_handle_broadcast_message(msg, host_ip)

func _on_peer_connected(id: int) -> void:
	peer_connected.emit(id)

func get_my_id() -> int:
	return uid

func get_peers() -> Array[int]:
	return all_peers

func is_host() -> bool:
	return is_server

func host_game(port: int) -> bool:
	var err := peer.create_server(port, 2)
	if err != OK:
		printerr("创建服务器失败: ", err)
		return false
	multiplayer.multiplayer_peer = peer
	uid = multiplayer.get_unique_id()
	all_peers = [uid]
	# 启动广播
	start_broadcast(port)
	return true

func join_game(ip: String, port: int) -> bool:
	var err := peer.create_client(ip, port)
	if err != OK:
		printerr("加入失败: ", err)
		return false
	multiplayer.multiplayer_peer = peer
	uid = multiplayer.get_unique_id()
	all_peers = [uid]
	# 停止监听
	stop_listen()
	return true

func disconnect_peer() -> void:
	connected = false
	is_game_host = false
	my_name = ""
	opponent_name = ""
	is_server = false
	uid = 0
	multiplayer.multiplayer_peer = null
	peer.close()
	all_peers = [1]
	# 停止广播和监听
	stop_broadcast()
	stop_listen()

# ========== UDP 广播/监听 ==========

func start_broadcast(game_port: int) -> void:
	if broadcast_socket:
		return
	broadcast_socket = PacketPeerUDP.new()
	broadcast_socket.set_broadcast_enabled(true)
	# 创建定时器
	if not broadcast_timer:
		broadcast_timer = Timer.new()
		broadcast_timer.wait_time = GlobalCfg.broadcast_interval
		broadcast_timer.autostart = true
		broadcast_timer.one_shot = false
		broadcast_timer.timeout.connect(_do_broadcast)
		add_child(broadcast_timer)
	else:
		broadcast_timer.start()
	# 存储游戏端口
	_game_port = game_port

var _game_port: int = 0

func _do_broadcast() -> void:
	if not broadcast_socket or not is_server:
		return
	var msg: String = JSON.stringify({
		"host_name": my_name,
		"game_port": _game_port
	})
	# 向局域网广播
	var interfaces: Array = IP.get_local_interfaces()
	for interface in interfaces:
		var ips: Array = interface["addresses"]
		for ip in ips:
			if ip.contains("."):
				# 构造广播地址
				var parts: Array = ip.split(".")
				if parts.size() == 4:
					var broadcast_ip: String = "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]
					broadcast_socket.set_dest_address(broadcast_ip, GlobalCfg.broadcast_port)
					broadcast_socket.put_packet(msg.to_utf8_buffer())

func stop_broadcast() -> void:
	if broadcast_timer:
		broadcast_timer.stop()
	if broadcast_socket:
		broadcast_socket.close()
		broadcast_socket = null

func start_listen() -> void:
	stop_listen()
	listen_socket = PacketPeerUDP.new()
	var err: int = listen_socket.bind(GlobalCfg.broadcast_port)
	if err != OK:
		printerr("监听广播失败: ", err)
		listen_socket = null
		return
	discovered_hosts = []

func stop_listen() -> void:
	if listen_socket:
		listen_socket.close()
		listen_socket = null
	discovered_hosts = []

func _handle_broadcast_message(msg: String, host_ip: String) -> void:
	var json: JSON = JSON.new()
	var err: int = json.parse(msg)
	if err != OK: return
	var data: Dictionary = json.data
	var host_info: Dictionary = {
		"ip": host_ip,
		"host_name": data.get("host_name", "未知主机"),
		"game_port": data.get("game_port", GlobalCfg.game_port)
	}
	# 检查是否已存在
	for existing in discovered_hosts:
		if existing["ip"] == host_ip:
			return
	discovered_hosts.append(host_info)
	host_discovered.emit(host_info)

func get_discovered_hosts() -> Array[Dictionary]:
	return discovered_hosts

# ---- 名字交换 RPC ----
@rpc("any_peer")
func exchange_name(player_name: String) -> void:
	opponent_name_received.emit(player_name)
	if multiplayer.is_server():
		all_peers.append(multiplayer.get_remote_sender_id())
	else:
		# 客户端收到服务端的名字，确保 1 在第一位以保持一致排序
		if not all_peers.has(1):
			all_peers.insert(0, 1)

# ---- 游戏邀请 RPC ----
@rpc("any_peer")
func request_game(game_id: String) -> void:
	game_invite_received.emit(game_id, opponent_name)

@rpc("any_peer")
func accept_game(game_id: String) -> void:
	game_invite_accepted.emit(game_id)

@rpc("any_peer")
func decline_game() -> void:
	game_invite_declined.emit()

# ---- 棋盘操作 RPC ----
@rpc("any_peer")
func send_name(player_name: String) -> void:
	if multiplayer.is_server():
		player_name_received.emit(player_name, true)
		all_peers.append(multiplayer.get_remote_sender_id())
	else:
		player_name_received.emit(player_name, false)
		all_peers.append(multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func set_board(x: int, y: int, color: int) -> void:
	board_set.emit(x, y, color)

@rpc("any_peer", "call_local")
func restart_game() -> void:
	restart_requested.emit()
