extends BTCondition

@export_category("Input")
@export var var_to_check: StringName

func _tick(_delta: float) -> Status:
    return Status.SUCCESS if blackboard.has_var(var_to_check) else Status.FAILURE
