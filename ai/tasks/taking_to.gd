extends BTAction

@export var anim_state: StringName = &"idle"

@export_category("Input")
@export var var_face_target: StringName = &"face_target"

func _enter() -> void:
    var target_pos: Vector2 = blackboard.get_var(var_face_target)
    if !target_pos:
        push_error("taking_to: no target position found")

    agent.update_direction(target_pos)
    agent.state = anim_state
    agent.move(Vector2.ZERO)
    agent.update_animation(anim_state)

func _tick(_delta: float) -> Status:
    return Status.RUNNING
