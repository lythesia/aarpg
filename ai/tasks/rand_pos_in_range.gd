## random pick postion within circle defined by center and radius
@tool
extends BTAction

@export var center: Vector2
@export var radius: float = 32
@export var min_distance_to_current: float = 15

@export_category("Output")
## blackboard variable that stores the random position within range(circle)
@export var var_target_pos: StringName = &"target_pos"

func _setup() -> void:
    var preview: ZonePreview = agent.get_node_or_null("ZonePreview") as ZonePreview
    if preview:
        center = preview.global_position
        radius = preview.radius * ZonePreview.GRID_SIZE
    else:
        center = agent.global_position
        push_warning("BTA(rand_pos_in_range): no zone preview under agent node!")

func _tick(_delta: float) -> Status:
    if radius <= 0:
        return Status.FAILURE

    var agent_pos: Vector2 = agent.global_position
    for _i in 32:
        var pos: Vector2 = center + Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(0, radius)
        if pos.distance_to(agent_pos) >= min_distance_to_current:
            blackboard.set_var(var_target_pos, pos)
            return Status.SUCCESS

    return Status.FAILURE
