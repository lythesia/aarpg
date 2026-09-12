## move one step towards a direction
@tool
extends BTAction

## BB variable of target direction (Vector2)
@export var target_dir: StringName = &"target_dir"

## step animation
@export var anim_state: StringName = &"walk"

@export var speed: float = 30
## duration of one step (float)
@export var step_dur: float = 0.7
## bounce off walls if true
@export var wall_check: bool = false

var dur: float
var dir: Vector2

func _generate_name() -> String:
    return "One Step Towards %s" % [
        LimboUtility.decorate_var(target_dir)
    ]

func _enter() -> void:
    dur = step_dur
    agent.update_animation(anim_state)
    dir = blackboard.get_var(target_dir)

func _tick(delta: float) -> Status:
    if not dir:
        return Status.FAILURE

    dur -= delta
    if wall_check and agent.is_on_wall():
        dir = dir.bounce(agent.get_wall_normal())
    if agent.update_direction(dir):
        agent.update_animation(anim_state)
    agent.move(dir * speed)
    if dur <= 0:
        return Status.SUCCESS
    return Status.RUNNING
