class_name PlayerStateWalk
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var speed: float = 100.0

func init():
    pass

func enter():
    player.update_animation("walk")

func exit():
    pass

func handle_input(event: InputEvent) -> PlayerState:
    if event.is_action_pressed("Dash"):
        return player.fsm.dash
    elif event.is_action_pressed("Attack"):
        return player.fsm.attack
    elif event.is_action_pressed("ui_accept"):
        PlayerManager.player_interact()
    return STAY

func process(_delta: float) -> PlayerState:
    if player.dir.is_zero_approx():
        return player.fsm.idle

    if player.update_direction():
        player.update_animation("walk")

    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = player.dir * speed
    return STAY
