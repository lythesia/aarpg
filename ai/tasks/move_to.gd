@tool
extends BTAction

## BB variable of target position (Vector2)
@export var target_pos: StringName = &"target_pos"

## move animation
@export var anim_state: StringName = &"walk"

@export var speed: float = 30
@export var tolerance: float = 5

var _target_pos: Vector2 = Vector2.ZERO
var should_fail: bool = false

func _generate_name() -> String:
    return "Move To %s" % [
        LimboUtility.decorate_var(target_pos)
    ]

func _enter() -> void:
    # reset
    should_fail = false

    _target_pos = blackboard.get_var(target_pos, Vector2.ZERO)
    if _target_pos == Vector2.ZERO:
        should_fail = true
        return

    if !is_arrived():
        var dir: Vector2 = agent.global_position.direction_to(_target_pos)
        agent.move(dir * speed)
        agent.update_direction(dir)
        agent.update_animation(anim_state)

func _tick(_delta: float) -> Status:
    if should_fail:
        return Status.FAILURE

    if is_arrived():
        return Status.SUCCESS
    else:
        return Status.RUNNING

func _exit() -> void:
    if is_arrived():
        blackboard.erase_var(target_pos)

func is_arrived() -> bool:
    return _target_pos.distance_to(agent.global_position) <= tolerance
