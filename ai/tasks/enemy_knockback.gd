extends BTAction

## BB variable of damage source position (Vector2)
@export var damage_source_pos: StringName = &"damage_source_pos"

## BB variable if stunned (bool)
@export var is_stunned: StringName = &"is_stunned"

## stun animation
@export var anim_state: StringName = &"stun"

@export var invulnerable_dur: float = 0.3
@export var knockback_speed: float = 200
@export var knockback_decelerate: float = 10

var enemy: Enemy
var dur: float

func _enter() -> void:
    enemy = agent as Enemy
    if enemy.animation_player.current_animation == enemy.get_animation(anim_state):
        enemy.animation_player.seek(0)
    else:
        enemy.update_animation(anim_state)

    enemy.damage_area.make_invulnerable(invulnerable_dur)

    dur = enemy.animation_player.current_animation_length
    var dmg_src_pos: Vector2 = blackboard.get_var(damage_source_pos) as Vector2
    var dir = dmg_src_pos.direction_to(enemy.global_position).normalized()
    if knockback_speed > 0:
        enemy.move(dir * knockback_speed)

func _tick(delta: float) -> Status:
    dur -= delta
    if knockback_decelerate > 0:
        enemy.velocity -= enemy.velocity * knockback_decelerate * delta
    if dur <= 0:
        return Status.SUCCESS
    return Status.RUNNING

func _exit() -> void:
    # unset `is_stunned` on exit
    blackboard.set_var(is_stunned, false)
