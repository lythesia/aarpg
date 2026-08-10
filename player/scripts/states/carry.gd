class_name PlayerStateCarry
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var move_speed: float = 100
@export var throw_audio: AudioStream

var is_walking: bool = false
var throwable: Throwable

func init():
    pass

func enter():
    is_walking = false
    player.update_animation("carry")

func exit():
    # todo: drop/throw by input?
    if throwable:
        # setup throw direction
        throwable.throw_dir = player.cardinal_dir
        if player.fsm.next_state == player.fsm.stun:
            # drop
            throwable.drop()
        else:
            # throw
            Audio.play_spatial_sound(throw_audio, player.global_position)
            throwable.throw()

    throwable = null

func handle_input(event: InputEvent) -> PlayerState:
    if event.is_action_pressed("ui_accept"):
        return player.fsm.idle
    return STAY

func process(_delta: float) -> PlayerState:
    if player.dir == Vector2.ZERO:
        is_walking = false
        player.update_animation("carry")
    # dir not zero: 1. dir changed; 2. !walking -> walking
    elif player.update_direction() or !is_walking:
        is_walking = true
        player.update_animation("carry_walk")

    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = player.dir * move_speed
    is_walking = player.dir != Vector2.ZERO
    return STAY
