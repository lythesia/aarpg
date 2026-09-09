extends Node

@onready var pcam: PhantomCamera2D = %PhantomCamera2D

var orig_tween_dur: float = 1.0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

    # set limit target when scene loaded
    SceneManager.scene_loaded.connect(_on_scene_loaded)

    # only teleport to player during fade_in of scene loading, after that
    # we reset the tween duration
    orig_tween_dur = pcam.get_tween_duration()
    PlayerManager.PlayerRepositioned.connect(_on_player_repositioned, CONNECT_ONE_SHOT)

func _on_scene_loaded() -> void:
    var base_tilemap_layer: TileMapLayer = _get_scene_base_tilemap_layer()
    if base_tilemap_layer:
        pcam.set_limit_target(base_tilemap_layer.get_path())

func _get_scene_base_tilemap_layer() -> TileMapLayer:
    var scene: Node = get_tree().current_scene
    var c: Node = scene.find_child("Base*")
    if c is TileMapLayer and (c as TileMapLayer).enabled:
        return c
    return null

func _on_player_repositioned() -> void:
    # remember `tween_on_load` needs to be false
    pcam.set_tween_duration(0)
    pcam.teleport_position()
    pcam.tween_completed.connect(_on_first_tween_completed, CONNECT_ONE_SHOT)

func _on_first_tween_completed() -> void:
    pcam.set_tween_duration(orig_tween_dur)
