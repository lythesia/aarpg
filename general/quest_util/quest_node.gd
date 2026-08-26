@tool
class_name QuestNode extends Node

@export var quest: Quest: set = set_quest
@export var step: int: set = set_step
@export var is_completed: bool: set = set_is_completed

@export_category("Info only")
@export_multiline var summary: String

func set_quest(value: Quest) -> void:
    quest = value
    update_configuration_warnings()
    update_summary()

func set_step(value: int) -> void:
    step = clampi(value, 0, _get_steps_count())
    update_summary()

func set_is_completed(value: bool) -> void:
    is_completed = value
    update_summary()

func _get_steps_count() -> int:
    if !quest:
        return 0

    return quest.steps.size()

func _get_step() -> String:
    if step > 0 and step <= _get_steps_count():
        return quest.steps[step - 1]
    else:
        return "N/A"

func update_summary() -> void:
    if !quest:
        summary = "Quest is not set"
        return

    summary = r"UPDATE QUEST:
- Quest: %s
- Step: %d %s
- Complete: %s" % [quest.title, step, _get_step(), is_completed]

func _get_configuration_warnings() -> PackedStringArray:
    if !quest:
        return PackedStringArray(["Quest is not set"])

    return []
