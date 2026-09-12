@tool
extends BTAction

@export var var_counter: StringName = &"counter"
@export var min_count: int = 1
@export var max_count: int = 3

func _generate_name() -> String:
    return "Random Counter: -> %s" % [LimboUtility.decorate_var(var_counter)]

func _tick(_delta: float) -> Status:
    var count: int = randi_range(min_count, max_count)
    blackboard.set_var(var_counter, count)
    return Status.SUCCESS
