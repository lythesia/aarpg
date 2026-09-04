class_name PlayerStateDash
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var move_speed: float = 250
@export var effect_delay: float = 0.05
@export var dash_audio: AudioStream

var dash_dir: Vector2 = Vector2.ZERO
var effect_timer: float = 0.0

func init():
    pass

func enter():
    player.damage_area.start_invulnerable()
    player.update_animation("dash")
    player.anim_player.animation_finished.connect(_on_animation_finished)
    Audio.play_spatial_sound(dash_audio, player.global_position)
    dash_dir = player.dir if !player.dir.is_zero_approx() else player.cardinal_dir
    effect_timer = effect_delay

func exit():
    player.anim_player.animation_finished.disconnect(_on_animation_finished)
    player.damage_area.end_invulnerable()

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    effect_timer -= _delta
    if effect_timer <= 0:
        effect_timer = effect_delay
        player.sprite.ghost()

    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = dash_dir * move_speed
    return STAY

func _on_animation_finished(_anim: String) -> void:
    player.fsm.change_state(player.fsm.idle)
