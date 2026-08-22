class_name CameraHelper extends Node

@onready var pcam: PhantomCamera2D = %PhantomCamera2D

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    var base_tilemap_layer: TileMapLayer = _get_base_tilemap_layer()
    if base_tilemap_layer:
        pcam.set_limit_target(base_tilemap_layer.get_path())
    PlayerManager.PlayerRepositioned.connect(_on_player_repositioned)

func _get_base_tilemap_layer() -> TileMapLayer:
    var scene: Node = owner
    var c: Node = scene.find_child("Base*")
    if c is TileMapLayer and (c as TileMapLayer).enabled:
        return c
    return null

func _on_player_repositioned(player: Player) -> void:
    pcam.set_tween_duration(0.0)
    pcam.set_follow_target(player)
    pcam.teleport_position()
