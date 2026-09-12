@tool
extends BTAction

@export var min_count: int = 1
@export var max_count: int = 3

## BB variable (output) of counter (int)
@export var counter: StringName = &"counter"

func _generate_name() -> String:
    return "Random Counter %s" % [LimboUtility.decorate_output_var(counter)]

func _tick(_delta: float) -> Status:
    var count: int = randi_range(min_count, max_count)
    blackboard.set_var(counter, count)
    return Status.SUCCESS
