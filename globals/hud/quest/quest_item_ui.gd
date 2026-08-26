class_name QuestItemUI extends Button

@onready var title_label: Label = $TitleLabel
@onready var step_label: Label = $StepLabel

var quest: Quest

func _ready() -> void:
    pass

func initialize(data: Quest, state: Dictionary) -> void:
    self.quest = data
    title_label.text = data.title

    if state.is_completed:
        step_label.text = "Completed"
        step_label.modulate = Color.LIGHT_GREEN
    else:
        var step_count: int = data.steps.size()
        step_label.text = "steps: %d/%d" % [state.completed_steps, step_count]
