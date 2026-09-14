@tool
extends BTAction

## preview node in scene contains teleport positions
@export var preview_node: BBNode

## BB variable of result: Array[Dictionary { pos: Vector2, face: Vector2 }]
@export var result_var: StringName = &"teleport_positions"

func _generate_name() -> String:
    return "Gather Teleports %s %s" % [
        preview_node.to_string() if preview_node else "???",
        LimboUtility.decorate_output_var(result_var)
    ]

func _tick(_delta: float) -> Status:
    var _preview_node: Node = preview_node.get_value(scene_root, blackboard) as Node
    if !_preview_node:
        return Status.FAILURE

    var result: Array[Dictionary] = []
    for c in _preview_node.get_children():
        var p: Node2D = c as Node2D
        var pos: Vector2 = p.global_position
        var face: Vector2
        if p.name.containsn("top"):
            face = Vector2.DOWN
        elif p.name.containsn("bottom"):
            face = Vector2.UP
        elif p.name.containsn("left"):
            face = Vector2.RIGHT
        else:
            face = Vector2.LEFT
        result.append({"pos": pos, "face": face})
    blackboard.set_var(result_var, result)

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
