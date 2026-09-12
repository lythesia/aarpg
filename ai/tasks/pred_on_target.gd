@tool
extends BTCondition

## BB variable of target to be checked
@export var target: StringName = &"target"

## function name to be called on target
@export var pred_func: StringName

func _generate_name() -> String:
    return "if %s.%s()" % [
        LimboUtility.decorate_var(target),
        pred_func
    ]

func _tick(_delta: float) -> Status:
    var _target: Node = blackboard.get_var(target)
    if _target and is_instance_valid(_target) and _target.has_method(pred_func):
        return Status.SUCCESS if _target.call(pred_func) else Status.FAILURE
    return Status.FAILURE
