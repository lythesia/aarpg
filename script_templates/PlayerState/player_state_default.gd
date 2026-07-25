# class_name PlayerState STATE
extends PlayerState
# meta-name: PlayerState
# meta-description: Boilerplate player state script
# meta-default: true

# Included in PlayerState
# static var player: Player
# var next_state: PlayerState

func init():
    pass

func enter():
    pass

func exit():
    pass

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(_delta: float) -> PlayerState:
    return STAY
