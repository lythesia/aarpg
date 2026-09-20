@abstract
class_name QuestStep extends Resource

@warning_ignore("unused_signal")
signal Updated

enum CompleteMode {
    LATCH, LIVE,
}

@export var complete_mode: CompleteMode
@export_multiline var description: String
@export var is_completed: bool = false:
    set(v):
        if !locked:
            is_completed = v

var locked: bool = false

## invoke when quest start
@abstract
func on_start() -> void

## check if step can be completed, and set `is_completed` if possible
@abstract
func check_condition() -> bool

## state reload, connect signals (e.g. step status update)
func on_load() -> void:
    pass

## in some case we want to lock step's completed status
## e.g. submit quest to complete
func set_locked(val: bool) -> void:
    locked = val
