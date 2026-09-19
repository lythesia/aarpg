class_name QuestItemUI extends Button

@onready var title_label: Label = $TitleLabel
@onready var step_label: Label = $StepLabel

var quest: BaseQuest

func _ready() -> void:
    pass

func initialize(q: BaseQuest, is_completed: bool) -> void:
    self.quest = q
    title_label.text = q.quest_name

    if is_completed:
        step_label.text = "Completed"
        step_label.modulate = Color.LIGHT_GREEN
    else:
        step_label.text = "steps: %d/%d" % [
            q.get_completed_steps_count(), q.get_steps_count()
        ]
