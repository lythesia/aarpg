class_name PlayerStateWalk
extends PlayerState

# Included in PlayerState
# static var player: Player
# var next_state: PlayerState

@export var speed: float = 100.0

func init():
    pass

func enter():
    player.update_animation("walk")

func exit():
    pass

func handle_input(_event: InputEvent) -> PlayerState:
    return next_state

func process(_delta: float) -> PlayerState:
    if player.dir.is_zero_approx():
        return player.fsm.idle

    if player.update_sprite_direction():
        player.update_animation("walk")

    return next_state

func physics_process(_delta: float) -> PlayerState:
    player.velocity = player.dir * speed
    return next_state
