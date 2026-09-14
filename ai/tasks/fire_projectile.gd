@tool
extends BTAction

## projectile spawner node
@export var spawner: BBNode: set = _set_spawner


## delay before firing projectile
@export var fire_delay: float = 0

func _generate_name() -> String:
    return "%s Fire" % [spawner.to_string() if spawner else "???"]

func _tick(_delta: float) -> Status:
    var _spawner: ProjectileSpawner = spawner.get_value(scene_root, blackboard, agent) as ProjectileSpawner
    if !_spawner:
        return Status.FAILURE

    _spawner.fire_at_player(fire_delay)
    return Status.SUCCESS

func _set_spawner(v: BBNode) -> void:
    spawner = v
    emit_changed()
    if Engine.is_editor_hint() and spawner and !spawner.changed.is_connected(emit_changed):
        spawner.changed.connect(emit_changed)

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if !spawner:
        warnings.append("Projectile spawner not set")
    elif spawner.value_source == BBNode.ValueSource.SAVED_VALUE and !spawner.saved_value:
        warnings.append("Path to projectile spawner not set")
    elif spawner.value_source == BBNode.ValueSource.BLACKBOARD_VAR and !spawner.variable:
        warnings.append("Blackboard variable not set")
    return warnings
