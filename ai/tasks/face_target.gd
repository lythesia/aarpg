extends BTAction

@export_category("Input")
@export var var_face_target: StringName = &"face_target"

func _tick(_delta: float) -> Status:
    var target: Node2D = blackboard.get_var(var_face_target)
    if !is_instance_valid(target):
        return FAILURE

    var dir: Vector2 = agent.global_position.direction_to(target.global_position)
    agent.move(Vector2.ZERO)
    agent.update_direction(dir)
    return SUCCESS
