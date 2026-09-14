@tool
extends BTAction

## preview node in scene contains beam attacks
@export var preview_node: BBNode

## BB variable of result: Array[BeamAttack]
@export var beams_h_var: StringName = &"beams_h"
## BB variable of result: Array[BeamAttack]
@export var beams_v_var: StringName = &"beams_v"

func _generate_name() -> String:
    return "Gather Beam Attacks %s %s %s" % [
        preview_node.to_string() if preview_node else "???",
        LimboUtility.decorate_output_var(beams_h_var),
        LimboUtility.decorate_output_var(beams_v_var)
    ]

func _tick(_delta: float) -> Status:
    var _preview_node: Node = preview_node.get_value(scene_root, blackboard) as Node
    if !_preview_node:
        return Status.FAILURE

    var beams_h: Array[BeamAttack] = []
    var beams_v: Array[BeamAttack] = []
    for c in _preview_node.get_children():
        if c is BeamAttack:
            if c.name.containsn("_h"):
                beams_h.append(c)
            elif c.name.containsn("_v"):
                beams_v.append(c)
    blackboard.set_var(beams_h_var, beams_h)
    blackboard.set_var(beams_v_var, beams_v)
    return Status.SUCCESS

func _set_preview_node(v: BBNode) -> void:
    preview_node = v
    emit_changed()
    if Engine.is_editor_hint() and !preview_node.changed.is_connected(emit_changed):
        preview_node.changed.connect(emit_changed)

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if !preview_node:
        warnings.append("Preview node not set")
    elif preview_node.value_source == BBNode.ValueSource.SAVED_VALUE and !preview_node.saved_value:
        warnings.append("Path to preview node not set")
    elif preview_node.value_source == BBNode.ValueSource.BLACKBOARD_VAR and !preview_node.variable:
        warnings.append("Blackboard variable not set")
    return warnings
