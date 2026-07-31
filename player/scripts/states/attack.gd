class_name PlayerStateAttack
extends PlayerState

# Included in PlayerState
# static var player: Player
# var next_state: PlayerState

@export var attack_audio: AudioStream

var is_attacking: bool

func init():
    pass

func enter():
    player.update_animation("attack")
    if attack_audio:
        Audio.play_spatial_sound(attack_audio, player.global_position, randf_range(0.9, 1.1))
    is_attacking = true
    player.anim_player.animation_finished.connect(_on_attack_finished)

func exit():
    is_attacking = false
    player.anim_player.animation_finished.disconnect(_on_attack_finished)
    # force hide smear sprite
    player.smear_sprite.visible = false

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    if is_attacking:
        return STAY
    elif player.dir.is_zero_approx():
        return player.fsm.idle
    else:
        return player.fsm.walk

func physics_process(_delta: float) -> PlayerState:
    return STAY

func _on_attack_finished(_anim: String):
    is_attacking = false
