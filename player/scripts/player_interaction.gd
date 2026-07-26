# activate area when player press "interaction"
# detect by target area's _on_entered
@tool
class_name PlayerInteraction extends Area2D

@onready var player: Player = owner

func _ready() -> void:
    if Engine.is_editor_hint():
        return
    player.DirectionChanged.connect(_update_direction)

func _update_direction(cardinal_dir: Vector2):
    match cardinal_dir:
        Vector2.DOWN:
            rotation_degrees = 0
        Vector2.UP:
            rotation_degrees = 180
        Vector2.LEFT:
            rotation_degrees = 90
        Vector2.RIGHT:
            rotation_degrees = -90

func _get_configuration_warnings() -> PackedStringArray:
    if !_is_owner_player():
        return ["Owner must be a Player"]
    return []

func _is_owner_player() -> bool:
    return owner is Player
