class_name CameraHelper extends Node

@onready var pcam: PhantomCamera2D = %PhantomCamera2D
# @onready var host: PhantomCameraHost = $Camera2D/PhantomCameraHost

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

    # host.pcam_became_active.connect(func(p: PhantomCamera2D):
    #     print("%s(%s) became active prio=%d" % [p.name, p.owner.get_parent().name, p.get_priority()])
    # )
    # host.pcam_became_inactive.connect(func(p: PhantomCamera2D):
    #     print("%s(%s) became inactive prio=%d" % [p.name, p.owner.get_parent().name, p.get_priority()])
    # )

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
