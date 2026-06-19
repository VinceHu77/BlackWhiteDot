extends Control
class_name OnlineHUD

@onready var black_seat: Label = $BlackSeat
@onready var white_seat: Label = $WhiteSeat

func set_black_seat(player_name: String) -> void:
	black_seat.text = player_name

func set_white_seat(player_name: String) -> void:
	white_seat.text = player_name
