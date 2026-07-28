extends Node

var _target_level_trans: String
var _offset: Vector2

func _ready() -> void:
    SceneManager.process_mode = Node.PROCESS_MODE_ALWAYS

    SceneManager.scene_loaded.connect(_on_scene_loaded)

    # SceneHelper is autoload, so await for scene to be ready
    # todo: may not need it if we have main scene?
    await get_tree().process_frame
    Messages.ChangeSceneFinished.emit()

func _pause():
    get_tree().paused = true

func _resume():
    get_tree().paused = false

func _on_scene_loaded():
    print("on_scene_loaded: %s" % SceneManager._current_scene.name)
    if !_target_level_trans:
        return

    Messages.NewSceneLoaded.emit(_target_level_trans, _offset)

# 1. pause
# 2. await fade out
# 3. change scene
# 4. await changed
# 5. signal: new scene place player
# 6. fade in
# 7. resume
# 8. signal: new scene enable area monitoring
func change_scene(
    target_scene: String,
    target_level_trans: String,
    player: Player,
    _velocity: Vector2,
    time_to_pass: float,
    offset: Vector2
):
    # store
    _target_level_trans = target_level_trans
    _offset = offset

    # disable player hit boxes
    player.damage_area.set_deferred("monitorable", false)
    # todo: need `AutoWalk` state if we want to auto walk player pass through transition

    # expect pause to be called after fade out
    get_tree().create_timer(time_to_pass).timeout.connect(_pause)

    await SceneManager.change_scene(target_scene)
    Messages.ChangeSceneFinished.emit()

    player.damage_area.set_deferred("monitorable", true)
    _resume()

    # clear
    _target_level_trans = ""
    _offset = Vector2.ZERO
