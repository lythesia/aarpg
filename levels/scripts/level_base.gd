@tool
class_name Level extends Node2D

func _ready() -> void:
    # enable y-sort
    y_sort_enabled = true

    if Engine.is_editor_hint():
        return

    # wait player
    var player: Player = null

    while player == null:
        player = PlayerManager.get_player()
        await get_tree().process_frame

    # grab base tilemap layer
    var base_tilemap_layer: TileMapLayer = _get_base_tilemap_layer()
    base_tilemap_layer.get_path()

    # create player camera
    _create_player_camera(player, base_tilemap_layer)

    # emit
    Messages.LoadSceneFinished.emit()

func _get_configuration_warnings() -> PackedStringArray:
    if !_get_base_tilemap_layer():
        return ["Requires base tilemap layer named 'Base*'!"]
    return []

## the most bottom layer of map named "Base*", which defines the boundary/limit of level
func _get_base_tilemap_layer() -> TileMapLayer:
    for c in find_children("Base*", "TileMapLayer"):
        return c as TileMapLayer
    return null

# Cam
#  +-- Camera2D
#  |   +-- PhantomCameraHost
#  +-- PhantomCamera2D
func _create_player_camera(player: Player, base_tilemap_layer: TileMapLayer):
    var container: Node = Node.new()
    container.name = "Cam"

    var base_cam: Camera2D = Camera2D.new()
    base_cam.name = "Camera2D"
    var phantom_cam_host: PhantomCameraHost = PhantomCameraHost.new()
    phantom_cam_host.name = "PhantomCameraHost"
    base_cam.add_child(phantom_cam_host)
    container.add_child(base_cam)

    var cam: PhantomCamera2D = PhantomCamera2D.new()
    cam.name = "PhantomCamera2D"
    cam.follow_mode = PhantomCamera2D.FollowMode.SIMPLE
    cam.tween_on_load = false
    container.add_child(cam)

    add_child(container)

    _setup_camera.call_deferred(cam, player, base_tilemap_layer)


func _setup_camera(cam: PhantomCamera2D, player: Player, base_tilemap_layer: TileMapLayer):
    cam.set_limit_target(base_tilemap_layer.get_path())
    cam.set_follow_target(player)
    cam.teleport_position()
    await get_tree().process_frame
