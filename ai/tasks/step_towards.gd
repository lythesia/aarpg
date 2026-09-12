## move one step
extends BTAction

@export var speed: float = 30
@export var anim_state: StringName = &"walk"
@export var step_dur: float = 0.7
@export var wall_check: bool = false

@export_category("Input")
@export var var_target_dir: StringName = &"target_dir"

var dur: float
var dir: Vector2

func _enter() -> void:
    dur = step_dur
    agent.update_animation(anim_state)
    dir = blackboard.get_var(var_target_dir)

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
