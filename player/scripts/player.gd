class_name Player extends CharacterBody2D

signal DirectionChanged(dir: Vector2)

@onready var sprite: PlayerSprite = %Sprite
@onready var smear_sprite: Sprite2D = %SmearSprite
@onready var attack_area: AttackArea = %AttackArea
@onready var spin_attack_area: AttackArea = %SpinAttackArea
@onready var spin_aura_attack_area: AttackArea = %SpinAuraAttackArea
@onready var spin_anim_player: AnimationPlayer = %SpinAnimPlayer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var effect_anim_player: AnimationPlayer = $EffectAnimationPlayer
@onready var fsm: PlayerStateMachine = %PlayerStateMachine
@onready var damage_area: DamageArea = %DamageArea
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var held_item: Node2D = $Sprite/HeldItem
@onready var camera_emitter: PhantomCameraNoiseEmitter2D = %PlayerCameraNoiseEmitter

@onready var label: Label = $Label

# cardinal direction to set sprite direction, only can be one of [Up, Down, Left, Right]
var cardinal_dir: Vector2 = Vector2.DOWN

# actual moving direction
var dir: Vector2 = Vector2.ZERO

# var input_vector: Vector2 = Vector2.ZERO

const DEFAULT_HP: int = 6
var hp: int = 6:
    set(value):
        hp = clampi(value, 0, max_hp)
        PlayerHud.update_hp(hp, max_hp)
var max_hp: int = 6

# used for game load, setup player stats after scene change instead of on load
var player_to_load: Dictionary = {}

func _init() -> void:
    PlayerManager.set_player(self)

func _ready() -> void:
    fsm.init(self)
    PlayerHud.update_hp(hp, max_hp)
    update_attack_damage()
    PlayerManager.PlayerLeveledUp.connect(_on_player_leveled_up)

func _unhandled_input(_event: InputEvent) -> void:
    # if event.is_action_pressed("Test"):
    #     shake_trauma()
    pass

# func _unhandled_input(_event: InputEvent) -> void:
#     var x_axis = Input.get_axis("Left", "Right")
#     var y_axis = Input.get_axis("Up", "Down")
#     if x_axis != 0 or y_axis != 0:
#         input_vector = Vector2(x_axis, y_axis).normalized()
#     else:
#         input_vector = Vector2.ZERO

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

    var new_cardinal: Vector2 = Utils.calc_cardinal_dir(dir + 0.2 * cardinal_dir)

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

func _dir_str(cardinal: Vector2) -> String:
    match cardinal:
        Vector2.UP:
            return "up"
        Vector2.DOWN:
            return "down"
        _:
            return "side"

## player animation naming rule: [anim_state]_[up/down/side]
func update_animation(anim_state: String) -> String:
    var anim: String = "%s_%s" % [anim_state, _dir_str(cardinal_dir)]
    anim_player.play(anim)
    return anim_player.current_animation

func _debug_label(_delta: float):
    # var args = [global_position]
    # label.text = "%v" % args
    pass

#region player_stats
var level: int = 1
var xp: int = 0
var base_atk: int = 1:
    set(v):
        atk += v - base_atk
        base_atk = v
var base_def: int = 1:
    set(v):
        def += v - base_def
        base_def = v
var atk: int = 1:
    set(v):
        atk = v
        update_attack_damage()
var def: int = 1:
    set(v):
        def = v

func update_attack_damage() -> void:
    attack_area.damage_amount = atk
    spin_attack_area.damage_amount = atk
    spin_aura_attack_area.damage_amount = atk
#endregion

#region abilities & gears
const MAX_ARROW_COUNT: int = 99
const MAX_BOMB_COUNT: int = 99
var arrow_count: int = 0:
    set(v):
        arrow_count = clampi(v, 0, MAX_ARROW_COUNT)
var bomb_count: int = 0:
    set(v):
        bomb_count = clampi(v, 0, MAX_BOMB_COUNT)
#endregion

#region save/load
func save_to_dict(s: SaveKitSerializer) -> Dictionary:
    return {
        "scene": ResourceUID.uid_to_path(SceneHelper.current_scene),
        "pos": s.encode_var(global_position),
        "hp": hp,
        "max_hp": max_hp,
        "level": level,
        "xp": xp,
        "base_atk": base_atk,
        "base_def": base_def,
        "arrow_count": arrow_count,
        "bomb_count": bomb_count,
    }

func load_from_dict(d: SaveKitDeserializer, data: Dictionary) -> void:
    var scene: String = data.get("scene", SceneHelper.DEFAULT_SCENE)
    SceneHelper.scene_to_load = ResourceUID.path_to_uid(scene) # used to change scene later

    var decoded = d.decode_var(data["pos"], TYPE_VECTOR2)
    player_to_load = {
        "pos": decoded if decoded is Vector2 else Vector2.ZERO,
        "hp": data.get("hp", DEFAULT_HP),
        "max_hp": data.get("max_hp", DEFAULT_HP),
        "level": data.get("level", 1),
        "xp": data.get("xp", 0),
        "base_atk": data.get("atk", 1),
        "base_def": data.get("def", 1),
        "arrow_count": data.get("arrow_count", 0),
        "bomb_count": data.get("bomb_count", 0),
    }
#endregion

# utils
func setup_player_on_load() -> void:
    PlayerManager.set_player_global_position(player_to_load["pos"])
    hp = player_to_load["hp"]
    max_hp = player_to_load["max_hp"]
    level = player_to_load["level"]
    xp = player_to_load["xp"]
    base_atk = player_to_load["base_atk"]
    base_def = player_to_load["base_def"]

func lift_item(throwable: Throwable) -> void:
    # shift throwable_object from parent to player's held item
    var object = throwable.throwable_object
    object.reparent(held_item, false) # don't keep global position
    object.position = Vector2.ZERO # re-position according to held item
    fsm.change_state(fsm.lift)
    fsm.carry.throwable = throwable # ref throwable NOT object!

func is_dead() -> bool:
    return hp <= 0 and fsm.current_state is PlayerStateDeath

func heal() -> void:
    hp = max_hp

func revive() -> void:
    hp = max_hp
    fsm.change_state(fsm.idle)

func shake_trauma() -> void:
    camera_emitter.emit()

# signal handler
func _on_player_leveled_up() -> void:
    effect_anim_player.play("level_up")
