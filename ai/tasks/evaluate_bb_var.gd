@tool
extends BTAction

## BB variable of object to evaluate
@export var variable: StringName

## property of object to evaluate
@export var property: StringName

## BB variable of result
@export var result_var: StringName

func _generate_name() -> String:
    return "Evaluate %s.%s %s" % [
        LimboUtility.decorate_var(variable),
        property,
        LimboUtility.decorate_output_var(result_var)]

func _tick(_delta: float) -> Status:
    var obj: Object = blackboard.get_var(variable)
    if !obj:
        return Status.FAILURE
    var val = obj.get(property)
    if !val:
        return Status.FAILURE
    blackboard.set_var(result_var, val)
    return Status.SUCCESS
