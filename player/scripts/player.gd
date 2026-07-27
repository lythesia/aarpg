class_name Player extends CharacterBody2D

signal DirectionChanged(dir: Vector2)

@onready var sprite: Sprite2D = %Sprite
@onready var sprite_material: ShaderMaterial = sprite.material as ShaderMaterial
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var effect_anim_player: AnimationPlayer = $EffectAnimationPlayer
@onready var fsm: PlayerStateMachine = %PlayerStateMachine
@onready var damage_area: DamageArea = %DamageArea

@onready var label: Label = $Label

# cardinal direction to set sprite direction, only can be one of [Up, Down, Left, Right]
var cardinal_dir: Vector2 = Vector2.DOWN

# actual moving direction
var dir: Vector2 = Vector2.ZERO

var hp: int = 5
var max_hp: int = 6

func _ready() -> void:
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
    var args = [dir, cardinal_dir]
    label.text = "D: %v\nC: %v" % args
    pass
