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

func handle_input(event: InputEvent) -> PlayerState:
    if event.is_action_pressed("Attack"):
        return player.fsm.attack
    elif event.is_action_pressed("ui_accept"):
        PlayerManager.PlayerInteracted.emit()
    return STAY

func process(_delta: float) -> PlayerState:
    if !player.dir.is_zero_approx():
        return player.fsm.walk
    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    return STAY
