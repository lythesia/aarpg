class_name Player extends CharacterBody2D

signal DirectionChanged(dir: Vector2)

@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var effect_anim_player: AnimationPlayer = $EffectAnimationPlayer
@onready var fsm: PlayerStateMachine = %PlayerStateMachine
@onready var damage_area: DamageArea = %DamageArea
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var label: Label = $Label

# cardinal direction to set sprite direction, only can be one of [Up, Down, Left, Right]
var cardinal_dir: Vector2 = Vector2.DOWN

# actual moving direction
var dir: Vector2 = Vector2.ZERO

const DEFAULT_HP: int = 6
var hp: int = 6:
    set(value):
        hp = clampi(value, 0, max_hp)
        PlayerHud.update_hp(hp, max_hp)
var max_hp: int = 6

# used for game load, setup player stats after scene change instead of on load
var player_to_load: Dictionary = {}

func _ready() -> void:
    PlayerManager.set_player(self)
    fsm.init(self)
    PlayerHud.update_hp(hp, max_hp)

func _process(delta: float) -> void:
    _update_direction()
    _debug_label(delta)

func _physics_process(_delta: float) -> void:
    move_and_slide()

func _update_direction():
    # states now allowed to input change direcion
    if fsm.current_state in []:
        return

    var x_axis = Input.get_axis("Left", "Right")
    var y_axis = Input.get_axis("Up", "Down")

    # moving direction
    dir = Vector2(x_axis, y_axis).normalized()

func update_direction() -> bool:
    if dir == Vector2.ZERO:
        return false

    # cleaver! and give honor to original cardinal direction
    const CLOCKWISE: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
    var idx = round(((dir + 0.2 * cardinal_dir).angle() / TAU) * 4)
    var new_cardinal: Vector2 = CLOCKWISE[idx]

    if new_cardinal == cardinal_dir:
        return false
    cardinal_dir = new_cardinal

    # handle horizontal flip
    # use scale not flip_h coz player may have children need flip also
    if cardinal_dir == Vector2.LEFT:
        sprite.scale.x = -1.0
    else:
        sprite.scale.x = 1.0

    DirectionChanged.emit(cardinal_dir)

    return true

func _cardinal_dir_to_string(cardinal: Vector2) -> String:
    match cardinal:
        Vector2.UP:
            return "up"
        Vector2.DOWN:
            return "down"
        _:
            return "side"

## player animation naming rule: [anim_state]_[up/down/side]
func update_animation(anim_state: String) -> String:
    var anim: String = "%s_%s" % [anim_state, _cardinal_dir_to_string(cardinal_dir)]
    anim_player.play(anim)
    return anim_player.current_animation

func _debug_label(_delta: float):
    var args = [global_position]
    label.text = "%v" % args
    pass

#region save/load
func save_to_dict(s: SaveKitSerializer) -> Dictionary:
    return {
        "scene": ResourceUID.uid_to_path(SceneHelper.current_scene),
        "pos": s.encode_var(global_position),
        "hp": hp,
        "max_hp": max_hp,
    }

func load_from_dict(d: SaveKitDeserializer, data: Dictionary) -> void:
    var scene: String = data.get("scene", SceneHelper.DEFAULT_SCENE)
    SceneHelper.scene_to_load = ResourceUID.path_to_uid(scene) # used to change scene later

    var decoded = d.decode_var(data["pos"], TYPE_VECTOR2)
    player_to_load = {
        "pos": decoded if decoded is Vector2 else Vector2.ZERO,
        "hp": data.get("hp", DEFAULT_HP),
        "max_hp": data.get("max_hp", DEFAULT_HP),
    }
#endregion

func setup_player_on_load() -> void:
    PlayerManager.set_player_global_position(player_to_load["pos"])
    hp = player_to_load["hp"]
    max_hp = player_to_load["max_hp"]
