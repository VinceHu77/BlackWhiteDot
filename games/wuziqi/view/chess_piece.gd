extends Node2D
class_name ChessPiece

var grid_pos: Vector2i = Vector2i(-1, -1)
var color: int = WuziqiCfg.Player.NONE

func _init(pos: Vector2i, piece_color: int, cell_size: int) -> void:
	grid_pos = pos
	color = piece_color
	position = Vector2(pos.x * cell_size, pos.y * cell_size)
