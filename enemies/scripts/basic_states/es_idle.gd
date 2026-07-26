class_name EsIdle extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

@export var idle_dur_min: float = 0.5
@export var idle_dur_max: float = 1.0
var dur: float = 0.0
var ended: bool = false

func enter() -> void:
    enemy.update_animation(anim_name)
    dur = randf_range(idle_dur_min, idle_dur_max)
    ended = false

func re_enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    enemy.velocity = Vector2.ZERO
    dur -= _delta
    if dur <= 0.0:
        ended = true
