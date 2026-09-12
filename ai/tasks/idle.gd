extends BTAction

## idle animation
@export var anim_state: StringName = &"idle"

func _enter() -> void:
    agent.move(Vector2.ZERO)
    agent.update_animation(anim_state)

func _tick(_delta: float) -> Status:
    return Status.RUNNING
