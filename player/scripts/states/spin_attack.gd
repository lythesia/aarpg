class_name PlayerStateSpinAttack
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var spin_audio: AudioStream

var is_attacking: bool = false

func init():
    pass

func enter():
    player.anim_player.play("spin_attack")
    player.anim_player.seek(_spin_start(player.cardinal_dir))
    player.spin_anim_player.play("default")
    Audio.play_spatial_sound(spin_audio, player.global_position)

    var dur: float = player.anim_player.current_animation_length * 0.875
    get_tree().create_timer(dur).timeout.connect(func(): is_attacking = false)

    player.velocity = Vector2.ZERO # no moving while spinning
    is_attacking = true
    player.spin_attack_area.set_active(true)

func _spin_start(dir: Vector2) -> float:
    # time offset when spin start from (down, up, side)
    const SPIN_INTERVAL: float = 1.5

    match dir:
        Vector2.DOWN: return 0
        Vector2.UP: return SPIN_INTERVAL
        _: return SPIN_INTERVAL * 2

func exit():
    player.spin_attack_area.set_active(false)

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    if !is_attacking:
        return player.fsm.idle
    return STAY

func physics_process(_delta: float) -> PlayerState:
    return STAY
