@tool
extends BTRepeat

## BB variable of repeat count of child task
@export var counter: StringName = &"counter"

func _generate_name() -> String:
    return "Repeat: %s times" % [LimboUtility.decorate_var(counter)]

func _enter() -> void:
    times = blackboard.get_var(counter, 1)
