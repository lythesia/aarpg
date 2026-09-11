extends BTAction

@export_category("Output")
@export var var_target_pos: StringName = &"target_pos"
@export var var_time_limit: StringName = &"time_limit"

var next_idx: int = 0

func _tick(_delta: float) -> Status:
    # last one not arrived, resume it
    if blackboard.has_var(var_target_pos):
        print("next_loc: resume")
        return Status.SUCCESS

    var partol_preview: PartrolPreview = agent.get_node_or_null("PatrolPreview")
    if !partol_preview:
        push_warning("next_patrol_loc: no patrol preview found")
        return Status.FAILURE
    if partol_preview.patrol_locations.size() < 2:
        push_warning("next_patrol_loc: not enough patrol locations, at least 2 required")
        return Status.FAILURE

    var loc: PatrolLocation = partol_preview.patrol_locations[next_idx]
    blackboard.set_var(var_target_pos, loc.target_pos)
    blackboard.set_var(var_time_limit, loc.wait_time)
    next_idx = (next_idx + 1) % partol_preview.patrol_locations.size()
    return Status.SUCCESS
