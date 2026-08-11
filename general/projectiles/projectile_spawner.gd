class_name ProjectileSpawner extends Marker2D

@export var projectile: PackedScene


func _ready() -> void:
    if owner is Enemy:
        owner.DirectionChanged.connect(_on_direction_changed)

func fire(target_position: Vector2, delay: float = 0.0) -> void:
    if not projectile:
        return

    if delay > 0:
        await get_tree().create_timer(delay).timeout

    var p = projectile.instantiate()
    get_tree().root.add_child(p)
    p.global_position = global_position

    if p is Projectile:
        p.start(target_position)

func fire_at_player(delay: float = 0.0) -> void:
    var player = PlayerManager.get_player()
    if player:
        fire(player.global_position + Vector2(0.0, -18.0), delay) # todo: make offset configurable

func _on_direction_changed(new_dir: Vector2) -> void:
    match new_dir:
        Vector2.UP: rotation_degrees = 180
        Vector2.DOWN: rotation_degrees = 0
        Vector2.LEFT: rotation_degrees = 90
        Vector2.RIGHT: rotation_degrees = -90
