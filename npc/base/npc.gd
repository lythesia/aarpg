@tool
@icon("res://npc/assets/icons/npc.svg")
class_name NPC extends CharacterBody2D

signal DoBehave

@export var npc_res: NPCResource: set = _set_npc_res
@export var npc_dialog: DialogueResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $InteractArea
@onready var interact_hint: Sprite2D = $InteractHint

var state: String = "idle"
var dir: Vector2 = Vector2.ZERO
var cardinal_dir: Vector2 = Vector2.DOWN
var can_behave: bool = true

func _ready() -> void:
    setup_npc()
    if Engine.is_editor_hint():
        return

    interact_area.area_entered.connect(_on_area_entered)
    interact_area.area_exited.connect(_on_area_exited)
    interact_hint.modulate.a = 0.0

    DoBehave.emit()

func _physics_process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return
    # $Label.text = "%s:%s" % [state, str(global_position)]
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

var tween: Tween

func _on_area_entered(_area: Area2D) -> void:
    PlayerManager.PlayerInteracted.connect(_on_player_interacted)
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(interact_hint, "modulate:a", 1.0, 0.5)

func _on_area_exited(_area: Area2D) -> void:
    PlayerManager.PlayerInteracted.disconnect(_on_player_interacted)
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(interact_hint, "modulate:a", 0.0, 0.5)

func _on_player_interacted() -> void:
    update_direction(PlayerManager.get_player().global_position)
    state = "idle"
    velocity = Vector2.ZERO
    update_animation()
    can_behave = false
    DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
    DialogueManager.show_dialogue_balloon(npc_dialog, "start", [
        {
            player = PlayerManager.get_player(),
            inventory = PlayerManager.INVENTORY_DATA,
        }
    ])

func _on_dialogue_finished(_res) -> void:
    DialogueManager.dialogue_ended.disconnect(_on_dialogue_finished)
    state = "idle"
    update_animation()
    can_behave = true
    DoBehave.emit()
