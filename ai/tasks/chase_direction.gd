@tool
extends BTAction

## BB variable of hint direction (Vector2) from PathFinder
@export var path_finder_hint: StringName = &"path_finder_hint"

## BB variable (output) of target direction (Vector2) to chase
@export var target_dir: StringName = &"target_dir"

@export var turn_rate: float = 0.25

var dir: Vector2 = Vector2.ZERO

func _generate_name() -> String:
    return "Chase Direction: %s %s" % [
        LimboUtility.decorate_var(path_finder_hint),
        LimboUtility.decorate_output_var(target_dir)
    ]

func _tick(_delta: float) -> Status:
    if !blackboard.has_var(path_finder_hint):
        return Status.FAILURE
    var hint_dir: Vector2 = blackboard.get_var(path_finder_hint)
    dir = lerp(dir, hint_dir, turn_rate)
    blackboard.set_var(target_dir, dir)
    return Status.SUCCESS
