@tool
extends BTDecorator

## BB variable of time limit in seconds
@export var time_limit: StringName = &"time_limit"

var timer: float

func _generate_name() -> String:
    return "Time Limit %s sec" % [LimboUtility.decorate_var(time_limit)]

func _enter() -> void:
    if !blackboard.has_var(time_limit):
        push_error("Blackboard variable %s not found." % LimboUtility.decorate_var(time_limit))
    else:
        timer = blackboard.get_var(time_limit)

func _tick(delta: float) -> Status:
    if !blackboard.has_var(time_limit):
        return Status.FAILURE

    if get_child_count() == 0:
        return Status.FAILURE

    var st: Status = get_child(0).execute(delta)
    if st == Status.RUNNING and timer <= 0:
        get_child(0).abort()
        return Status.FAILURE
    timer -= delta
    return st

func _exit() -> void:
    blackboard.erase_var(time_limit)
