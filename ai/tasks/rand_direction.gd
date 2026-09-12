@tool
extends BTAction

## BB variable (output) of target direction (Vector2)
@export var target_dir: StringName = &"target_dir"

func _generate_name() -> String:
    return "Random Direction %s" % [LimboUtility.decorate_output_var(target_dir)]

func _tick(_delta: float) -> Status:
    var dir: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
    blackboard.set_var(target_dir, dir)
    return Status.SUCCESS
