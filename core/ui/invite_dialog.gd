extends PanelContainer
class_name InviteDialog

signal accepted(game_id: String)
signal declined()

@onready var message_lbl: RichTextLabel = $VBoxContainer/MessageLbl
@onready var accept_btn: Button = $VBoxContainer/HBoxContainer/AcceptBtn
@onready var decline_btn: Button = $VBoxContainer/HBoxContainer/DeclineBtn

var _game_id: String = ""

func _ready() -> void:
	hide()
	accept_btn.pressed.connect(_on_accept)
	decline_btn.pressed.connect(_on_decline)

func show_invite(game_id: String, from_name: String) -> void:
	_game_id = game_id
	var game_display := MenuUI.new().get_display_name(game_id)
	message_lbl.text = "[color=#0099ff]%s[/color] 邀请你玩 [color=#55ff55]%s[/color]" % [from_name, game_display]
	show()

func _on_accept() -> void:
	hide()
	accepted.emit(_game_id)

func _on_decline() -> void:
	hide()
	declined.emit()
