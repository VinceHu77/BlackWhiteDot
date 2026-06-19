extends Node
class_name BaseModeBus

@warning_ignore_start("unused_signal")
signal game_win(result:int)    # 对局结束
signal toast_tip(msg:String)   # 弹窗提示
signal mode_back_to_menu()     # 返回菜单
