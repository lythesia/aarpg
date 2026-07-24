class_name PlayerStateIdle
extends PlayerState

# Included in PlayerState
# static var player: Player
# var next_state: PlayerState

func init():
    pass

func enter():
    player.update_animation("idle")

func exit():
    pass

func handle_input(_event: InputEvent) -> PlayerState:
    return next_state

func process(_delta: float) -> PlayerState:
    if !player.dir.is_zero_approx():
        return player.fsm.walk
    return next_state

func physics_process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    return next_state
