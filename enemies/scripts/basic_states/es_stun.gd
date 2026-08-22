class_name EsStun
extends EnemyState

@export var invulnerable_dur: float = 0.3
@export var knockback_speed: float = 200
@export var knockback_decelerate: float = 10

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

var dur: float = 0.0
var tw: Tween

func enter() -> void:
    _start()

func re_enter() -> void:
    _start()

func exit() -> void:
    blackboard.can_decide = true

func physics_update(delta: float) -> void:
    dur -= delta
    if knockback_decelerate > 0.0:
        enemy.velocity -= enemy.velocity * knockback_decelerate * delta
    if dur <= 0.0:
        blackboard.can_decide = true

func _start():
    if enemy.animation_player.current_animation == enemy.get_animation(anim_name):
        enemy.animation_player.seek(0)
    else:
        enemy.update_animation(anim_name)
    # _tween_flash()

    enemy.damage_area.make_invulnerable(invulnerable_dur) # matches player one hit
    dur = enemy.animation_player.current_animation_length
    var dmg_src = blackboard.damage_source.global_position
    var dir = dmg_src.direction_to(enemy.global_position).normalized()
    if knockback_speed > 0.0:
        enemy.velocity = dir * knockback_speed
    blackboard.damage_source = null # clear damage source
    blackboard.can_decide = false # disable decision engine


func _tween_flash():
    if enemy.sprite.material is not ShaderMaterial:
        return

    if tw:
        tw.kill()
    tw = create_tween()
    tw.tween_method(_set_flash_amount, 0.0, 1.0, 0.0)
    tw.tween_method(_set_flash_amount, 1.0, 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _set_flash_amount(value: float):
    if enemy.sprite.material is ShaderMaterial:
        (enemy.sprite.material as ShaderMaterial).set_shader_parameter("flash_amount", value)
