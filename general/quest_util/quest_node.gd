@tool
class_name QuestNode extends Node

@export var quest_data: QuestData: set = set_quest
@export var step: int: set = set_step

@export_category("Info only")
@export_multiline var summary: String

func set_quest(value: QuestData) -> void:
    quest_data = value
    update_configuration_warnings()
    update_summary()

func set_step(value: int) -> void:
    step = clampi(value, 0, _get_steps_count())
    update_summary()

func _get_steps_count() -> int:
    if !quest_data:
        return 0

    return quest_data.quest().steps.size()

func _get_step() -> QuestStep:
    assert(step >= 0 and step <= _get_steps_count(), "Step out of range: %d" % step)
    return quest_data.quest().steps[step]

func update_summary() -> void:
    if !quest_data:
        summary = "Quest is not set"
        return

    var quest: BaseQuest = quest_data.quest()
    var quest_step: QuestStep = _get_step()

    summary = r"UPDATE QUEST:
- Quest: %s
- Step: [%d] %s
- Complete: %s" % [
        quest.quest_name,
        step,
        quest_step.description,
        quest_step.is_completed
    ]

func _get_configuration_warnings() -> PackedStringArray:
    if Utils.is_editing_own_scene(self):
        return []

    var warnings: PackedStringArray = []
    if !quest_data:
        warnings.append("Quest is not set")
    return warnings
