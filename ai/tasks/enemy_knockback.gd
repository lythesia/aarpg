extends BTAction

@export_category("Input")
@export var var_damage_source: StringName = &"damage_source"

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
    var dmg_src_pos: Vector2 = blackboard.damage_source.global_position
    var dir = dmg_src_pos.direction_to(enemy.global_position).normalized()
    if knockback_speed > 0:
        enemy.velocity = dir * knockback_speed
    blackboard.erase_var(var_damage_source)

func _tick(delta: float) -> Status:
    dur -= delta
    if knockback_decelerate > 0:
        enemy.velocity -= enemy.velocity * knockback_decelerate * delta
    if dur <= 0:
        return Status.SUCCESS
    return Status.RUNNING
