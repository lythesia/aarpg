class_name PlayerAbilities extends Node

const BOOMERANG: PackedScene = preload("uid://cse55h7xmknxa")

enum Ability {
    BOOMERANG, GRAPPLE, BOW, BOMB,
}

var selected_ability: Ability = Ability.BOOMERANG
var player: Player
var boomerang_instance: Boomerang

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
                pass
            Ability.BOMB:
                pass
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
