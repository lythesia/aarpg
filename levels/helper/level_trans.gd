@tool
@icon("res://public/icons/level_transition.svg")
class_name LevelTrans extends Node2D

enum SIDE {
    ## at left side
    LEFT,
    ## at right side
    RIGHT,
    ## at top
    TOP,
    ## at bottom
    BOTTOM,
}

#region exports
@export_category("Target")
## target scene file
@export_file("*.tscn") var target_level: String # avoid circular ref by using PackedScene instead of file path

## name of target scene's level transition
@export var target_name: String = ""

@export_category("Size & Position")
## player collision shape width with some margin
# i.e. given circle(2r = 20), then make it 25, 30 is appropriate
@export var margin_width: int = 32
const TOLERANCE: int = 5
@export var margin_top: int = 13 - 5 + TOLERANCE
@export var margin_bottom: int = 13 + 5 + TOLERANCE
const CELL_UNIT: int = 32

@export var center_offset: bool = false

## box size in mutiples of 32px
@export_range(2, 16, 1, "or_greater") var size: int = 2:
    set(val):
        size = val
        apply_area_settings()

## which side transition is placed
@export() var location: SIDE = SIDE.LEFT:
    set(val):
        location = val
        apply_area_settings()
#endregion

@onready var area: Area2D = $Area2D

func _ready() -> void:
    apply_area_settings() # ensure area is scaled correctly anyway

    if Engine.is_editor_hint():
        return

    Messages.NewSceneLoaded.connect(_on_new_scene_ready)
    Messages.ChangeSceneFinished.connect(_on_load_scene_finished)

var _is_transitioning: bool = false
func _on_player_entered(player: Player) -> void:
    # print("%s player_entered: is_transitioning=%s %v" % [name, _is_transitioning, player.global_position])
    if _is_transitioning: return

    _is_transitioning = true
    await SceneHelper.level_transition(target_level, target_name, player, get_offset(player))
    _is_transitioning = false

func _on_new_scene_ready(target: String, offset: Vector2) -> void:
    # target_name behaves like LT's id, to make sure `_on_new_scene_ready`
    # is called only by one of them in single scene
    if target == self.name:
        PlayerManager.set_player_global_position(self.global_position + offset)

func _on_load_scene_finished() -> void:
    area.monitoring = false # disable area collision detect
    # await PlayerManager.PlayerRepositioned
    area.body_entered.connect(_on_player_entered)
    for _f in range(2): # at least 2 frames, 1 won't work
        await get_tree().process_frame
    area.monitoring = true # enable

func apply_area_settings() -> void:
    # ensure area if when onready not invoked
    area = get_node_or_null("Area2D")
    if !area:
        return

    if location == SIDE.LEFT or location == SIDE.RIGHT:
        area.scale.y = size
        if location == SIDE.LEFT:
            area.scale.x = -1
        else:
            area.scale.x = 1
    else:
        area.scale.x = size
        if location == SIDE.TOP:
            area.scale.y = 1
        else:
            area.scale.y = -1

func get_offset(player: Node2D) -> Vector2:
    var offset = Vector2.ZERO
    var player_pos = player.global_position
    if location == SIDE.LEFT or location == SIDE.RIGHT:
        offset.y = player_pos.y - self.global_position.y if !center_offset else 0
        # on left => enter from right
        if location == SIDE.LEFT:
            offset.x = - (CELL_UNIT + margin_width) / 2.0
        else:
            offset.x = (CELL_UNIT + margin_width) / 2.0
    else:
        offset.x = player_pos.x - self.global_position.x if !center_offset else 0
        # on top => enter from bottom
        if location == SIDE.TOP:
            offset.y = - (CELL_UNIT / 2.0 + margin_top)
        else:
            offset.y = CELL_UNIT / 2.0 + margin_bottom
    return offset

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if target_level == "":
        warnings.append("Target level is not set")
    if target_name == "":
        warnings.append("Target level transition is not set")
    return warnings
