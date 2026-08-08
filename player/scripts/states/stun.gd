class_name PlayerStateStun
extends PlayerState

@export var knockback_speed: float = 80
@export var knockback_decelerate: float = 10
@export var invulnerable_dur: float = 0.8
@export var hit_audio: AudioStream

# Included in PlayerState
# static var player: Player

var dir: Vector2 = Vector2.ZERO
var init_velocity: Vector2 = Vector2.ZERO
var tw: Tween

func init():
    player.damage_area.DamageTaken.connect(_on_damage_taken)

func enter():
    player.update_animation("stun")
    player.anim_player.animation_finished.connect(_on_animation_finished)

    if hit_audio:
        Audio.play_spatial_sound(hit_audio, player.global_position)

    player.damage_area.make_invulnerable(invulnerable_dur)
    player.effect_anim_player.play("damaged")
    # _tween_flash()

    player.velocity = init_velocity

func exit():
    player.anim_player.animation_finished.disconnect(_on_animation_finished)

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(delta: float) -> PlayerState:
    # player.velocity = dir * knockback_speed
    player.velocity -= player.velocity * knockback_decelerate * delta
    return STAY

# this is triggered before `enter`
func _on_damage_taken(attack_area: AttackArea) -> void:
    dir = attack_area.global_position.direction_to(player.global_position).normalized()
    init_velocity = dir * knockback_speed
    player.update_direction()
    player.hp -= attack_area.damage_amount
    player.fsm.change_state(self)

func _on_animation_finished(_anim: String) -> void:
    player.fsm.change_state(player.fsm.idle)

# hit flash effect
func _tween_flash():
    if tw:
        tw.kill()
    tw = create_tween()
    tw.tween_method(_set_flash_amount, 0.0, 1.0, 0.0)
    tw.tween_method(_set_flash_amount, 1.0, 0.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _set_flash_amount(value: float):
    player.sprite_material.set_shader_parameter("flash_amount", value)
