extends BTDecorator

@export var min_time: float = 1.0
@export var max_time: float = 5.0
var timer: float

func _enter() -> void:
    timer = randf_range(min_time, max_time)

func _tick(delta: float) -> Status:
    if get_child_count() == 0:
        push_error("BT decorator has no child.")
        return Status.FAILURE

    var st: Status = get_child(0).execute(delta)
    if st == Status.RUNNING and timer <= 0:
        get_child(0).abort()
        return Status.FAILURE
    timer -= delta
    return st
