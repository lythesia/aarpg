extends Node

const DEFAULT_SCENE: String = "uid://cce13rldqs5om"
var scene_to_load: String
var current_scene: String = DEFAULT_SCENE

enum TransitionType {
    LEVEL,
    LOAD,
    RELOAD,
    NONE,
}
var _transition_type: TransitionType = TransitionType.NONE
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
    match _transition_type:
        TransitionType.RELOAD:
            var player: Player = PlayerManager.get_player()
            player.setup_player_on_load()
        TransitionType.LOAD:
            var player: Player = PlayerManager.get_player()
            var scene: Node = get_tree().current_scene
            PlayerManager.reparent_player_to_scene(scene)
            player.setup_player_on_load()
        # on level transition
        TransitionType.LEVEL:
            var scene: Node = get_tree().current_scene
            PlayerManager.reparent_player_to_scene(scene)
            Messages.NewSceneLoaded.emit(_target_level_trans, _offset)

func load_scene_and_setup_player(target_scene: String):
    PlayerManager.reparent_player_to_root()

    # `change_scene` if load to different scene
    if target_scene != current_scene:
        _transition_type = TransitionType.LOAD
        await SceneManager.change_scene(target_scene)
        current_scene = ResourceUID.path_to_uid(target_scene)
        _transition_type = TransitionType.NONE

    # `reload_scene` if load same scene
    else:
        _transition_type = TransitionType.RELOAD
        await SceneManager.reload_scene()
        _transition_type = TransitionType.NONE

    # always need to emit signal to activate level transition area in target scene
    Messages.ChangeSceneFinished.emit()

# 1. pause
# 2. await fade out
# 3. change scene
# 4. await changed
# 5. signal: new scene place player
# 6. fade in
# 7. resume
# 8. signal: new scene enable area monitoring
func level_transition(
    target_scene: String,
    target_level_trans: String,
    player: Player,
    offset: Vector2
):
    # store
    _transition_type = TransitionType.LEVEL
    _target_level_trans = target_level_trans
    _offset = offset

    _pause()
    PlayerManager.reparent_player_to_root()

    # disable player hit boxes
    player.damage_area.set_deferred("monitorable", false)
    # todo: need `AutoWalk` state if we want to auto walk player pass through transition

    await SceneManager.change_scene(target_scene, {
        # "on_fade_out": _pause,
        # "on_fade_in": _resume,
    })
    current_scene = ResourceUID.path_to_uid(target_scene)
    Messages.ChangeSceneFinished.emit()

    player.damage_area.set_deferred("monitorable", true)
    _resume()

    # clear
    _transition_type = TransitionType.NONE
    _target_level_trans = ""
    _offset = Vector2.ZERO
