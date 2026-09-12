@tool
extends BTAction

@export_category("Input")
@export var var_path_finder_hint: StringName = &"path_finder_hint"

@export_category("Output")
@export var var_target_dir: StringName = &"target_dir"

@export var turn_rate: float = 0.25

var dir: Vector2 = Vector2.ZERO

func _generate_name() -> String:
    return "Chase Direction: %s -> %s" % [LimboUtility.decorate_var(var_path_finder_hint), LimboUtility.decorate_var(var_target_dir)]

func _tick(_delta: float) -> Status:
    if !blackboard.has_var(var_path_finder_hint):
        return Status.FAILURE
    var path_finder_hint: Vector2 = blackboard.get_var(var_path_finder_hint)
    dir = lerp(dir, path_finder_hint, turn_rate)
    blackboard.set_var(var_target_dir, dir)
    return Status.SUCCESS
