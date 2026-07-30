extends Node

const DEFAULT_SCENE: String = "uid://cce13rldqs5om"
var scene_to_load: String
var current_scene: String = DEFAULT_SCENE
var is_reload: bool = false

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
    # print("on_scene_loaded: %s" % SceneManager._current_scene.name)
    # on (re)load
    if is_reload:
        setup_player()
        # clear flags
        is_reload = false
    # on level transition
    elif _target_level_trans:
        Messages.NewSceneLoaded.emit(_target_level_trans, _offset)

func load_scene_and_setup_player(target_scene):
    var player: Player = PlayerManager.get_player()
    if target_scene != current_scene:
        await SceneManager.change_scene(target_scene, {
            "on_ready": func(_scene): player.setup_player()
        })
        current_scene = ResourceUID.path_to_uid(target_scene)
    else:
        # "on_ready" hook not work in `reload_scene`, use `scene_loaded` signal to setup player
        is_reload = true
        await SceneManager.reload_scene()

    # always need to emit signal to activate level transition area in target scene
    Messages.ChangeSceneFinished.emit()

func setup_player():
    var player: Player = PlayerManager.get_player()
    if player:
        player.setup_player()

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
    current_scene = ResourceUID.path_to_uid(target_scene)
    Messages.ChangeSceneFinished.emit()

    player.damage_area.set_deferred("monitorable", true)
    _resume()

    # clear
    _target_level_trans = ""
    _offset = Vector2.ZERO
