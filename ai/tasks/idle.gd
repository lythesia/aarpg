extends BTAction

@export var anim_state: StringName = &"idle"

func _enter() -> void:
    agent.state = anim_state
    agent.move(Vector2.ZERO)
    agent.update_animation(anim_state)

func _tick(_delta: float) -> Status:
    return Status.RUNNING
