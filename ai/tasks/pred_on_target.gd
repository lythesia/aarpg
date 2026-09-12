@tool
extends BTCondition

@export_category("Input")
## target in blackboard to be checked
@export var var_target: StringName = &"target"

## function name to be called on target
@export var pred_func: StringName

func _generate_name() -> String:
    return "Pred on Target: %s" % LimboUtility.decorate_var(var_target)

func _tick(_delta: float) -> Status:
    var target: Node = blackboard.get_var(var_target)
    if target and is_instance_valid(target) and target.has_method(pred_func):
        return Status.SUCCESS if target.call(pred_func) else Status.FAILURE
    return Status.FAILURE
