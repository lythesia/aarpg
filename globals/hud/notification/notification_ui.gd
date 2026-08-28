## todo: I don't understand the layout when I want place container
## top-right, and make it grow left & bottom
class_name NotificationUI extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: Label = $MarginContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MessageLabel

var noti_queue: Array[Dictionary]

func _ready() -> void:
    hide()
    # display next notification when current one is finished
    animation_player.animation_finished.connect(display_notification.unbind(1))

func push_notification(title: String, message: String) -> void:
    noti_queue.append({
        title = title,
        message = message,
    })

    if animation_player.is_playing():
        return
    else:
        display_notification()

func display_notification() -> void:
    var noti = noti_queue.pop_front()
    if !noti:
        return

    noti = noti as Dictionary
    title_label.text = noti.title
    message_label.text = noti.message
    animation_player.play("popup")
