class_name PlayerAbilities extends Node

const BOOMERANG: PackedScene = preload("uid://cse55h7xmknxa")

enum Ability {
    BOOMERANG
}

var selected_ability: Ability = Ability.BOOMERANG
var player: Player
var boomerang_instance: Boomerang

func _ready() -> void:
    player = PlayerManager.get_player()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Skill"):
        match selected_ability:
            Ability.BOOMERANG:
                boomerang_ability()
            _:
                pass

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
