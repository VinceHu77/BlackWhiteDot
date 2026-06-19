extends Node2D
class_name WuziqiEatDraw

var config: WuziqiEatCfg
var pieces: Dictionary = {}

func set_config(cfg: WuziqiEatCfg) -> void:
	config = cfg

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not config:
		return
	var size := config.board_size
	var cell := config.cell_size
	for i in range(size):
		draw_line(
			Vector2(i * cell, 0),
			Vector2(i * cell, (size - 1) * cell),
			Color.BLACK,
			config.line_width
		)
		draw_line(
			Vector2(0, i * cell),
			Vector2((size - 1) * cell, i * cell),
			Color.BLACK,
			config.line_width
		)

func draw_piece(x: int, y: int, color: int) -> void:
	var piece_scene := config.black_chess_scene if color == WuziqiEatCfg.Player.BLACK else config.white_chess_scene
	var visual = piece_scene.instantiate()
	var chess_piece := WuziqiEatPiece.new(Vector2i(x, y), color, config.cell_size)
	chess_piece.add_child(visual)
	get_parent().add_child(chess_piece)
	pieces[Vector2i(x, y)] = chess_piece

func clear_pieces() -> void:
	for piece in pieces.values():
		piece.queue_free()
	pieces.clear()
