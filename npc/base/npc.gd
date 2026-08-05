@tool
@icon("res://npc/assets/icons/npc.svg")
class_name NPC extends CharacterBody2D

signal DoBehave

@export var npc_res: NPCResource: set = _set_npc_res

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var state: String = "idle"
var dir: Vector2 = Vector2.ZERO
var cardinal_dir: Vector2 = Vector2.DOWN
var can_behave: bool = true

func _ready() -> void:
    setup_npc()
    if Engine.is_editor_hint():
        return

    DoBehave.emit()

func _physics_process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return
    $Label.text = "%s:%s" % [state, str(global_position)]
    move_and_slide()

func update_animation() -> void:
    var anim: String = "%s_%s" % [state, _dir_str()]
    animation_player.play(anim)

func update_direction(target_pos: Vector2) -> void:
    dir = global_position.direction_to(target_pos)
    cardinal_dir = Utils.calc_cardinal_dir(dir)

    if cardinal_dir == Vector2.LEFT:
        sprite.flip_h = true
    elif cardinal_dir == Vector2.RIGHT:
        sprite.flip_h = false

func _dir_str() -> String:
    match cardinal_dir:
        Vector2.UP:
            return "up"
        Vector2.DOWN:
            return "down"
        _:
            return "side"

func setup_npc() -> void:
    if npc_res and sprite:
        sprite.texture = npc_res.sprite

func _set_npc_res(value: NPCResource) -> void:
    npc_res = value
    setup_npc()
