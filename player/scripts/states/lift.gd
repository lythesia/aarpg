class_name PlayerStateLift
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var lift_audio: AudioStream

func init():
    pass

func enter():
    player.update_animation("lift")
    player.anim_player.animation_finished.connect(_on_animation_finished.unbind(1))

    Audio.play_spatial_sound(lift_audio, player.global_position)

func exit():
    player.anim_player.animation_finished.disconnect(_on_animation_finished)

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    return STAY

func _on_animation_finished() -> void:
    player.fsm.change_state(player.fsm.carry)
