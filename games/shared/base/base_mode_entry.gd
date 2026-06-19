extends Node
class_name BaseModeEntry

@warning_ignore_start("unused_signal")
signal mode_finished(mode_id:String) # 退出当前模式，切回主菜单

# 进入游戏初始化（加载数据、创建总线、初始化视图）
func setup() -> void:
	push_error("子类必须重写setup")

# 销毁游戏、释放资源、清理节点
func destroy() -> void:
	push_error("子类必须重写destroy")

# 外部中途暂停/继续（联机/弹窗打断用）
func pause_game() -> void: pass
func resume_game() -> void: pass
