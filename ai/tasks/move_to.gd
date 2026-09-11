extends BTAction

@export var speed: float = 30
@export var tolerance: float = 5
@export var anim_state: StringName = &"walk"

@export_category("Input")
@export var var_target_pos: StringName = &"target_pos"

var target_pos: Vector2 = Vector2.ZERO
var should_fail: bool = false

func _enter() -> void:
    # reset
    should_fail = false

    target_pos = blackboard.get_var(var_target_pos, Vector2.ZERO)
    if target_pos == Vector2.ZERO:
        should_fail = true
        return

    if !is_arrived():
        var dir: Vector2 = agent.global_position.direction_to(target_pos)
        agent.state = anim_state
        agent.move(dir * speed)
        agent.update_direction(target_pos)
        agent.update_animation(anim_state)
        # agent should have methods: move, update_direction, update_animation

func _tick(_delta: float) -> Status:
    if should_fail:
        return Status.FAILURE

    if is_arrived():
        return Status.SUCCESS
    else:
        # in case interrupted by player (e.g. dialogue), we resume move here
        # todo: not graceful, we should have some atomic sequence to resume
        # if agent.state != anim_state or agent.velocity == Vector2.ZERO:
        #     var dir: Vector2 = agent.global_position.direction_to(target_pos)
        #     agent.state = anim_state
        #     agent.move(dir * speed)
        #     agent.update_direction(target_pos)
        #     agent.update_animation(anim_state)
        return Status.RUNNING

func _exit() -> void:
    if is_arrived():
        blackboard.erase_var(var_target_pos)

func is_arrived() -> bool:
    return target_pos.distance_to(agent.global_position) <= tolerance
