extends BaseModeBus
class_name WuziqiEatBus

@warning_ignore_start("unused_signal")
signal piece_placed(pos: Vector2i, color: int)
signal game_ended(winner: int)
signal turn_changed(player: int)
signal piece_count_changed(color: int, remaining: int)
