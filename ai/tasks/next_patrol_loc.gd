@tool
extends BTAction

@export var target_pos: StringName = &"target_pos"
@export var time_limit: StringName = &"time_limit"

var next_idx: int = 0

func _generate_name() -> String:
    return "Next Patrol Loc %s, Wait Time %s" % [
        LimboUtility.decorate_output_var(target_pos),
        LimboUtility.decorate_output_var(time_limit)
    ]

func _tick(_delta: float) -> Status:
    # last one not arrived, resume it
    if blackboard.has_var(target_pos):
        return Status.SUCCESS

    var partol_preview: PartrolPreview = agent.get_node_or_null("PatrolPreview")
    if !partol_preview:
        push_warning("next_patrol_loc: no patrol preview found")
        return Status.FAILURE
    if partol_preview.patrol_locations.size() < 2:
        push_warning("next_patrol_loc: not enough patrol locations, at least 2 required")
        return Status.FAILURE

    var loc: PatrolLocation = partol_preview.patrol_locations[next_idx]
    blackboard.set_var(target_pos, loc.target_pos)
    blackboard.set_var(time_limit, loc.wait_time)
    next_idx = (next_idx + 1) % partol_preview.patrol_locations.size()
    return Status.SUCCESS
