class_name PlayerStateDrawBow
extends PlayerState

# Included in PlayerState
# static var player: Player

func init():
    pass

func enter():
    player.update_animation("bow")
    player.anim_player.animation_finished.connect(_on_animation_finished)

func exit():
    player.anim_player.animation_finished.disconnect(_on_animation_finished)

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(_delta: float) -> PlayerState:
    return STAY

func _on_animation_finished(_anim: String) -> void:
    player.fsm.change_state(player.fsm.idle)
