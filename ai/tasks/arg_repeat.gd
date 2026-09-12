@tool
extends BTRepeat

@export var var_counter: StringName = &"counter"

func _generate_name() -> String:
    return "Repeat: %s times" % [LimboUtility.decorate_var(var_counter)]

func _enter() -> void:
    times = blackboard.get_var(var_counter, 1)
