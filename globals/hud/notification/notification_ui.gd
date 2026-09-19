class_name NotificationUI extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: Label = $MarginContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MessageLabel

var noti_queue: Array[Dictionary]

func _ready() -> void:
    hide()
    # display next notification when current one is finished
    animation_player.animation_finished.connect(display_notification.unbind(1))

    # connects quests states
    QuestManager.QuestStarted.connect(_on_quest_started)
    QuestManager.QuestStepUpdated.connect(_on_quest_step_updated)
    QuestManager.QuestCompleted.connect(_on_quest_completed)
    QuestManager.QuestRewarded.connect(_on_quest_rewarded)

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

func _on_quest_started(quest: BaseQuest) -> void:
    push_notification("Quest Start!", quest.quest_name)

func _on_quest_step_updated(quest_title: String, step: QuestStep) -> void:
    push_notification("Quest Updated!", "%s: %s" % [quest_title, step.description])

func _on_quest_completed(quest: BaseQuest) -> void:
    push_notification("Quest Completed!", quest.quest_name)

func _on_quest_rewarded(quest_title: String, msg: String) -> void:
    push_notification(r'"%s" Reward!' % [quest_title], msg)
