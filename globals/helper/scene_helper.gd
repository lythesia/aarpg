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

func _ready() -> void:
    SceneManager.process_mode = Node.PROCESS_MODE_ALWAYS
    SceneManager.scene_loaded.connect(_on_scene_loaded)

func _pause():
    get_tree().paused = true

func _resume():
    get_tree().paused = false

func _on_scene_loaded():
    # print("on_scene_loaded(%s): %s" % [TransitionType.keys()[_transition_type], SceneManager._current_scene.name])
    current_scene = ResourceUID.path_to_uid(SceneManager._current_scene.scene_file_path)
    match _transition_type:
        # load at same scene OR continue
        TransitionType.RELOAD:
            var player: Player = PlayerManager.get_player()
            var scene: Node = get_tree().current_scene
            PlayerManager.reattach_player(scene)
            player.setup_player_on_load()
        # load from different scene OR continue from different scene
        TransitionType.LOAD:
            var player: Player = PlayerManager.get_player()
            var scene: Node = get_tree().current_scene
            PlayerManager.reattach_player(scene)
            player.setup_player_on_load()
        # on level transition
        TransitionType.LEVEL:
            pass
        # other cases activate LT
        TransitionType.NONE:
            Messages.ChangeSceneFinished.emit()

func new_game_scene(scene: String = DEFAULT_SCENE):
    await SceneManager.change_scene(scene, {
        "on_fade_out": _load_on_fade_out
    })


## this is called after save file loaded
## if different scene, new player instance will be created before this
## but NOT if same scene, but `player_to_load` is set
func load_game_scene(target_scene: String):
    # `change_scene` if load to different scene
    if target_scene != current_scene:
        _transition_type = TransitionType.LOAD
        await SceneManager.fade_out({"on_fade_out": _load_on_fade_out})
        PlayerManager.detach_player()
        await SceneManager.change_scene(target_scene, {"skip_fade_out": true})
        _transition_type = TransitionType.NONE

    # `reload_scene` if load same scene
    else:
        _transition_type = TransitionType.RELOAD
        await SceneManager.fade_out({"on_fade_out": _reload_on_fade_out})
        PlayerManager.detach_player()
        await SceneManager.reload_scene({"skip_fade_out": true})
        _transition_type = TransitionType.NONE

    # always need to emit signal to activate level transition area in target scene
    Messages.ChangeSceneFinished.emit()
    PlayerManager.post_reposition_player()

# when completely black
func _load_on_fade_out() -> void:
    var player = PlayerManager.get_player()
    if player and player.is_dead():
        player.revive()
    # we make hud visible when black out, to avoid sudden appear after new scene fade in
    PlayerHud.show()

# when completely black
func _reload_on_fade_out() -> void:
    var player = PlayerManager.get_player()
    # when reload same scene with player dead, we need to revive player
    # coz player instance will not be re-created and replaced
    if player.is_dead():
        player.revive()
    PlayerHud.show()

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
    offset: Vector2
):
    # store
    _transition_type = TransitionType.LEVEL

    # _pause()

    await SceneManager.fade_out({
        # "on_fade_out":
    })
    PlayerManager.detach_player()

    await SceneManager.change_scene(target_scene, {"skip_fade_out": true, "skip_fade_in": true})
    var scene: Node = get_tree().current_scene
    PlayerManager.reattach_player(scene)
    Messages.NewSceneLoaded.emit(target_level_trans, offset)

    await SceneManager.fade_in({
        # "on_fade_in":
    })

    Messages.ChangeSceneFinished.emit()

    PlayerManager.post_reposition_player()

    # _resume()

    # clear
    _transition_type = TransitionType.NONE
