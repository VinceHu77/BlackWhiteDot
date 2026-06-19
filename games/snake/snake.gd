extends Node2D
class_name Snake

const PIECE_SCENE := preload("res://games/shared/prefabs/black_chess.tscn")
const PIECE_SIZE := 40.0

@onready var move_timer: Timer = $MoveTimer

var _snake: Array[Vector2] = []
var _direction: Vector2
var _pieces: Array[Node2D] = []
var _is_playing: bool = false

func setup() -> void:
	move_timer.timeout.connect(_on_move_snake)
	var center := (get_viewport().get_visible_rect().size / 2).floor()
	center = Vector2(
		floor(center.x / PIECE_SIZE) * PIECE_SIZE,
		floor(center.y / PIECE_SIZE) * PIECE_SIZE
	)
	for i in range(3):
		var seg_pos = center - Vector2(i * PIECE_SIZE, 0)
		_snake.append(seg_pos)
		var piece = PIECE_SCENE.instantiate()
		piece.position = seg_pos
		add_child(piece)
		_pieces.append(piece)
	_is_playing = true
	move_timer.start()

func _ready() -> void:
	setup()

func _on_move_snake():
	if not _is_playing:
		return
	var old_head = _snake[0]
	# 计算新蛇头
	var new_head = old_head + _direction * PIECE_SIZE

	# 从后往前遍历身体：每一节跟上前面一节的旧坐标
	for i in range(_snake.size() - 1, 0, -1):
		_snake[i] = _snake[i - 1]
		_pieces[i].position = _snake[i]

	# 单独更新头
	_snake[0] = new_head
	_pieces[0].position = new_head

func _input(event: InputEvent) -> void:
	if not _is_playing:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP, KEY_W:
				_direction = Vector2.UP
			KEY_DOWN, KEY_S:
				_direction = Vector2.DOWN
			KEY_LEFT, KEY_A:
				_direction = Vector2.LEFT
			KEY_RIGHT, KEY_D:
				_direction = Vector2.RIGHT
