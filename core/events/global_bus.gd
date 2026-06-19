extends Node

@warning_ignore_start("unused_signal")
signal mode_switch_requested(mode_id: String)
signal mode_loaded(mode_id: String)
signal mode_unloaded(mode_id: String)
signal global_toast(message: String)
signal save_requested()
signal settings_changed()
signal app_quit()
