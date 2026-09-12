@tool
extends BTCondition

@export_category("Input")
@export var var_to_check: StringName

func _generate_name() -> String:
    return "Has BB Var: %s" % LimboUtility.decorate_var(var_to_check)

func _tick(_delta: float) -> Status:
    # print("has var: %s? %s" % [var_to_check, blackboard.has_var(var_to_check)])
    return Status.SUCCESS if blackboard.has_var(var_to_check) else Status.FAILURE
