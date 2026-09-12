extends BTAction

## death animation
@export var anim_state: StringName = &"death"

func _enter() -> void:
    PlayerManager.gain_xp(agent.xp)
    agent.update_animation(anim_state)
    agent.animation_player.animation_finished.connect(agent.queue_free.unbind(1))

func _tick(_delta: float) -> Status:
    agent.move(Vector2.ZERO)
    return Status.RUNNING
