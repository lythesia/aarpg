@icon("res://addons/quest_system/assets/quest_resource.svg")
class_name BaseQuest extends Quest

# remember: ID must be set manually!

@export var steps: Array[QuestStep]
@export var reward_xp: int = 0
@export var rewards: Array[QuestReward]

# overrides
func start(_args: Dictionary = {}) -> void:
    for step in steps:
        step.on_start()
        step.Updated.connect(_on_step_updated.bind(step))
    started.emit()

# func update(_args: Dictionary = {}) -> void:
#     pass

func complete(_args: Dictionary = {}) -> void:
    for step in steps:
        if !step.check_condition():
            break
    completed.emit()

func _on_step_updated(step: QuestStep) -> void:
    QuestManager.QuestStepUpdated.emit(id, quest_name, step)

# utils
func get_steps_count() -> int:
    return steps.size()

func get_completed_steps_count() -> int:
    return steps.filter(func(step: QuestStep) -> bool: return step.is_completed).size()

func get_step(idx: int) -> QuestStep:
    if idx > steps.size():
        push_error("Quest step index out of bounds")
        return null
    return steps[idx]

func get_first_uncompleted_step() -> QuestStep:
    var vs: Array[QuestStep] = steps.filter(func(step: QuestStep) -> bool: return !step.is_completed)
    return vs.front()

func complete_step(idx: int) -> void:
    if idx > steps.size():
        push_error("Quest step index out of bounds")
        return
    steps[idx].is_completed = true

#region save/load
# overrides
func serialize() -> Dictionary:
    var steps_data: Array[bool] = []
    for step in steps:
        steps_data.append(step.is_completed)
    var data: Dictionary = {
        "objective_completed": objective_completed,
        "steps": steps_data,
    }
    return data

func deserialize(data: Dictionary) -> void:
    objective_completed = data.get("objective_completed", false)
    var steps_data: Array = data.get("steps", [])
    for i in steps_data.size():
        if steps_data[i] as bool == true:
            steps[i].is_completed = true

func on_load() -> void:
    for step in steps:
        step.on_load()
        step.Updated.connect(_on_step_updated.bind(step))
#endregion
