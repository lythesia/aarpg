class_name EsChase
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

@export var speed: float = 40.0
## how much enemy can turn direction during chasing
@export var turn_rate: float = 0.25

func enter() -> void:
    enemy.update_animation(anim_name)

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    var target_dir = enemy.global_position.direction_to(blackboard.target.global_position)
    var dir = lerp(blackboard.dir, target_dir, turn_rate)
    blackboard.dir = dir
    enemy.velocity = dir * speed
    if enemy.update_direction(dir):
        enemy.update_animation(anim_name)

func can_chase() -> bool:
    if !enemy or !blackboard.target:
        return false

    return true
