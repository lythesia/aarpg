extends BTDecorator

@export_category("Input")
@export var var_limit_time: StringName = &"time_limit"
var timer: float

func _enter() -> void:
    if !blackboard.has_var(var_limit_time):
        push_error("Blackboard variable %s not found." % var_limit_time)
    else:
        timer = blackboard.get_var(var_limit_time)

func _tick(delta: float) -> Status:
    if !blackboard.has_var(var_limit_time):
        push_error("Blackboard variable %s not found." % var_limit_time)
        return Status.FAILURE

    if get_child_count() == 0:
        push_error("BT decorator has no child.")
        return Status.FAILURE

    var st: Status = get_child(0).execute(delta)
    if st == Status.RUNNING and timer <= 0:
        get_child(0).abort()
        return Status.FAILURE
    timer -= delta
    return st

func _exit() -> void:
    blackboard.erase_var(var_limit_time)
