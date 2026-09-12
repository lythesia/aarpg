@tool
extends BTCondition

## BB variable to check if exists
@export var var_to_check: StringName

func _generate_name() -> String:
    return "Has BB Var: %s" % LimboUtility.decorate_var(var_to_check)

func _tick(_delta: float) -> Status:
    return Status.SUCCESS if blackboard.has_var(var_to_check) else Status.FAILURE
