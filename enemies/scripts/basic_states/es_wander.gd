class_name EsWander
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

@export var speed: float = 30.0

@export_category("AI")
@export var anim_length: float = 0.5
@export var anim_cycles_min: int = 1
@export var anim_cycles_max: int = 3

var dir: Vector2 = Vector2.ZERO
var dur: float = 0.0
var ended: bool = false

func enter() -> void:
    enemy.update_animation(anim_name)

    dur = randi_range(anim_cycles_min, anim_cycles_max) * anim_length
    dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
    ended = false

func re_enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(delta: float) -> void:
    enemy.blackboard.dir = dir

    enemy.velocity = dir * speed
    if enemy.update_direction(dir):
        enemy.update_animation(anim_name)

    dur -= delta
    if dur <= 0.0:
        ended = true
