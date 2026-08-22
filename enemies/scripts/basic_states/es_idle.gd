class_name EsIdle extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

@export var idle_dur_min: float = 0.5
@export var idle_dur_max: float = 1.0
var idle_inf: bool = false
var dur: float = 0.0
var ended: bool = false

func enter() -> void:
    enemy.update_animation(anim_name)
    if idle_dur_min == 0.0 and idle_dur_max == 0.0:
        idle_inf = true
    elif idle_dur_min != idle_dur_max:
        dur = randf_range(idle_dur_min, idle_dur_max)
    else:
        dur = idle_dur_min
    ended = false

func re_enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    enemy.velocity = Vector2.ZERO
    if not idle_inf:
        dur -= _delta
        if dur <= 0.0:
            ended = true
