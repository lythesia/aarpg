@tool
@icon("res://public/icons/quest_advance.png")
class_name QuestAdvanceTrigger extends QuestNode

func _ready() -> void:
    if Engine.is_editor_hint():
        return

## start the NEW quest
func start_quest() -> void:
    if !quest_data:
        return
    QuestManager.start_quest(quest_data.get_entity_id())

## complete `step` of specified quest [br]
## it invokes `check_condition` of the step, so it may not actually complete
func complete_step() -> bool:
    if !quest_data:
        return false
    var quest_step: QuestStep = _get_step()
    return quest_step.check_condition()
