@tool
extends BTDecorator

## BB variable of subtree (.tres loaded into BehaviorTree)
@export var subtree: BBVariant

func _generate_name() -> String:
    return "Dynamic Subtree: %s" % [
        subtree.to_string() if subtree else "???"
    ]

func _setup() -> void:
    if !subtree:
        push_error("Dynamic Subtree: No subtree set")
        return

    var bt: BehaviorTree = subtree.get_value(scene_root, blackboard) as BehaviorTree
    if bt and bt.get_root_task():
        var branch: BTTask = bt.get_root_task().clone()
        var subtree_bb: Blackboard
        # if subtree has plan, create new bb based on it and parent to current bb
        if bt.blackboard_plan:
            subtree_bb = bt.blackboard_plan.create_blackboard(agent, blackboard)
        # else, create empty bb and parent to current bb
        else:
            subtree_bb = Blackboard.new()
            subtree_bb.set_parent(blackboard)
        branch.initialize(agent, subtree_bb, scene_root)
        add_child(branch)
    else:
        push_error("Dynamic Subtree: No subtree or no root task found in subtree")

func _enter() -> void:
    # print("dyn_subtree _enter: ", blackboard.list_vars())
    pass

func _tick(delta: float) -> Status:
    var branch: BTTask = get_child(0) as BTTask
    return branch.execute(delta)

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if !subtree:
        warnings.append("Dynamic Subtree: No subtree set")
    return warnings
