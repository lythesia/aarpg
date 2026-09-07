class_name PlayerAbilities extends Node

const BOOMERANG: PackedScene = preload("uid://cse55h7xmknxa")
const BOMB: PackedScene = preload("uid://dlwdds08vw7p1")
const ARROW: PackedScene = preload("uid://bd851tbou8scp")

enum Ability {
    BOOMERANG, GRAPPLE, BOW, BOMB,
}

var selected_ability: Ability = Ability.BOOMERANG
var player: Player
var boomerang_instance: Boomerang
var bomb_instance: Node2D

func _ready() -> void:
    player = PlayerManager.get_player()
    PlayerHud.update_arrow_count_label(player.arrow_count)
    PlayerHud.update_bomb_count_label(player.bomb_count)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Skill"):
        match selected_ability:
            Ability.BOOMERANG:
                boomerang_ability()
            Ability.GRAPPLE:
                pass
            Ability.BOW:
                bow_ability()
            Ability.BOMB:
                bomb_ability()
    elif event.is_action_pressed("RB"):
        next_ability()
    elif event.is_action_pressed("LB"):
        prev_ability()

func next_ability() -> void:
    selected_ability = (selected_ability + 1) % Ability.size() as Ability
    PlayerHud.update_ability_ui(selected_ability, true)

func prev_ability() -> void:
    selected_ability = (selected_ability - 1 + Ability.size()) % Ability.size() as Ability
    PlayerHud.update_ability_ui(selected_ability, true)

func boomerang_ability() -> void:
    # only one at a time allowed
    # tests `null` and `is_instance_valid`
    if boomerang_instance:
        return

    var boomerang: Boomerang = BOOMERANG.instantiate()
    player.add_sibling(boomerang)
    boomerang.hazard_area.damage_amount = player.atk
    boomerang.global_position = player.global_position

    var throw_dir = player.cardinal_dir
    boomerang.throw(throw_dir)
    boomerang_instance = boomerang

func bow_ability() -> void:
    if player.arrow_count <= 0:
        return

    # only allowed in [idle, walk]
    if player.fsm.current_state not in [player.fsm.idle, player.fsm.walk]:
        return

    player.arrow_count -= 1
    PlayerHud.update_arrow_count_label(player.arrow_count)
    var arrow: Projectile = ARROW.instantiate()
    player.add_sibling(arrow)
    var fire_dir: Vector2 = player.cardinal_dir
    arrow.global_position = player.global_position + fire_dir * 32.0
    arrow.start_directed(fire_dir)

    player.fsm.change_state(player.fsm.draw_bow)

func bomb_ability() -> void:
    if player.bomb_count <= 0:
        return

    # only one at a time allowed
    if bomb_instance:
        return

    # only allowed in [idle, walk]
    if player.fsm.current_state not in [player.fsm.idle, player.fsm.walk]:
        return

    player.bomb_count -= 1
    PlayerHud.update_bomb_count_label(player.bomb_count)
    var bomb: Node2D = BOMB.instantiate()
    player.add_sibling(bomb)
    bomb_instance = bomb

    PlayerManager.interact_handled = false
    var throwable: Throwable = bomb.get_node("Throwable")
    # start animation offset in seconds
    # todo: better ways like enter with event
    player.fsm.lift.start_anime_offset = 0.15
    throwable._on_player_interacted()
