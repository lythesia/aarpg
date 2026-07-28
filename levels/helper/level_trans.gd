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
# i.e. given circle(r = 20), then make it 25, 30 is appropriate
@export var margin_width: int = 30
## player collision shape height with some margin
# i.e. given circle(r = 20), then make it 25, 30 is appropriate
@export var margin_height: int = 30
const CELL_UNIT: int = 32

## portal box size in mutiples of 32px
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

func _on_player_entered(player: Player) -> void:
    # prepare args
    const v: float = 100.0
    const time_to_pass: float = CELL_UNIT / v
    var velocity: Vector2 = Vector2.ZERO
    match location:
        LevelTrans.SIDE.LEFT:
            velocity = Vector2(-v, 0)
        LevelTrans.SIDE.RIGHT:
            velocity = Vector2(0, v)
        LevelTrans.SIDE.TOP:
            velocity = Vector2(0, -v)
        LevelTrans.SIDE.BOTTOM:
            velocity = Vector2(0, v)

    SceneHelper.change_scene(target_level, target_name, player as Player, velocity, time_to_pass, get_offset(player))

func _on_new_scene_ready(target: String, offset: Vector2) -> void:
    # target_name behaves like LT's id, to make sure `_on_new_scene_ready`
    # is called only by one of them in single scene
    if target == self.name:
        var player: Node2D = PlayerManager.get_player()
        player.global_position = self.global_position + offset

func _on_load_scene_finished() -> void:
    area.monitoring = false # disable area collision detect
    area.body_entered.connect(_on_player_entered)
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
        offset.y = player_pos.y - self.global_position.y
        # portal's on left => enter from right
        # offset player left-wise to (target portal which's on right)
        if location == SIDE.LEFT:
            offset.x = - (CELL_UNIT + margin_width) / 2.0
        else:
            offset.x = (CELL_UNIT + margin_width) / 2.0
    else:
        offset.x = player_pos.x - self.global_position.x
        # portal's on top => enter from bottom
        # offset player up-wise to (target portal which's on bottom)
        if location == SIDE.TOP:
            offset.y = - (CELL_UNIT + margin_height) / 2.0
        else:
            offset.y = (CELL_UNIT + margin_height) / 2.0
    return offset

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if target_level == "":
        warnings.append("Target level is not set")
    if target_name == "":
        warnings.append("Target level transition is not set")
    return warnings
