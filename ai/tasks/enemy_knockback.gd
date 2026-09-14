extends BTAction

## BB variable of damage source position (Vector2)
@export var damage_source_pos: StringName = &"damage_source_pos"

## BB variable if stunned (bool)
@export var is_stunned: StringName = &"is_stunned"

## stun animation
@export var anim_state: StringName = &"stun"

## default: 0.3s
@export var invulnerable_dur: BBFloat
## default: 200
@export var knockback_speed: BBFloat
## default: 10
@export var knockback_decelerate: BBFloat

var enemy: Enemy
var dur: float

func _enter() -> void:
    enemy = agent as Enemy
    if enemy.animation_player.current_animation == enemy.get_animation(anim_state):
        enemy.animation_player.seek(0)
    else:
        enemy.update_animation(anim_state)

    var idur: float = invulnerable_dur.get_value(scene_root, blackboard, 0.3)
    enemy.damage_area.make_invulnerable(idur)

    dur = enemy.animation_player.current_animation_length
    var dmg_src_pos: Vector2 = blackboard.get_var(damage_source_pos) as Vector2
    var dir = dmg_src_pos.direction_to(enemy.global_position).normalized()
    var speed: float = knockback_speed.get_value(scene_root, blackboard, 200)
    if speed > 0:
        enemy.move(dir * speed)

func _tick(delta: float) -> Status:
    dur -= delta
    var decel: float = knockback_decelerate.get_value(scene_root, blackboard, 10)
    if decel > 0:
        enemy.velocity -= enemy.velocity * decel * delta
    if dur <= 0:
        return Status.SUCCESS
    return Status.RUNNING

func _exit() -> void:
    # unset `is_stunned` on exit
    blackboard.set_var(is_stunned, false)
