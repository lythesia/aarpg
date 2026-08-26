@tool
@icon("res://public/icons/quest_advance.png")
class_name QuestAdvanceTrigger extends QuestNode

func _ready() -> void:
    if Engine.is_editor_hint():
        return

func accept_quest() -> void:
    if !quest:
        return

    await get_tree().process_frame
    QuestManager.accept_quest(quest.title)

func advance_request() -> void:
    if !quest:
        return

    await get_tree().process_frame
    QuestManager.accept_or_advance_quest(quest.title)
