class_name PlayerStateDeath
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var death_audio: AudioStream

func init():
    pass

func enter():
    player.anim_player.play("death")
    Audio.play_spatial_sound(death_audio, player.global_position)

    player.collision.disabled = true
    player.damage_area.queue_free()

    # show screen
    PlayerHud.show_game_over()

func exit():
    pass

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    return STAY
