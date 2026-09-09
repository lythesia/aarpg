class_name PlayerAbilities extends Node

const BOOMERANG: PackedScene = preload("uid://cse55h7xmknxa")
const BOMB: PackedScene = preload("uid://dlwdds08vw7p1")
const ARROW: PackedScene = preload("uid://bd851tbou8scp")

enum Ability {
    BOOMERANG, GRAPPLE, BOW, BOMB,
}

var abilities: Array[Ability] = [] # should ordered as: [BOOMERANG, GRAPPLE, BOW, BOMB]
var selected_ability: Ability
var player: Player
var boomerang_instance: Boomerang
var bomb_instance: Node2D

func _ready() -> void:
    player = PlayerManager.get_player()
    update_ability_ui()
    PlayerManager.INVENTORY_DATA.GainAbility.connect(add_ability)

func set_abilities(vs: Array) -> void:
    for v in vs:
        if v is int or v is Ability:
            var a: Ability = v as Ability
            if a not in abilities:
                abilities.append(a)
    if !vs.is_empty():
        selected_ability = vs[0]

    update_ability_ui()

func add_ability(a: Ability) -> void:
    if a in abilities:
        return
    abilities.append(a)
    abilities.sort() # keep ordered
    # the first ability added
    if abilities.size() == 1:
        selected_ability = a

    update_ability_ui()

func update_ability_ui() -> void:
    PlayerHud.update_abilitiy_items(abilities, selected_ability)
    PauseMenu.ability_container.update_ability_items(abilities)

    if Ability.BOW in abilities:
        PlayerHud.update_arrow_count_label(player.arrow_count)
    if Ability.BOMB in abilities:
        PlayerHud.update_bomb_count_label(player.bomb_count)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Skill"):
        if abilities.is_empty():
            return
        match selected_ability:
            Ability.BOOMERANG:
                boomerang_ability()
            Ability.GRAPPLE:
                grapple_ability()
            Ability.BOW:
                bow_ability()
            Ability.BOMB:
                bomb_ability()
    elif event.is_action_pressed("RB"):
        next_ability()
    elif event.is_action_pressed("LB"):
        prev_ability()

func next_ability() -> void:
    var idx: int = abilities.find(selected_ability)
    if idx == -1:
        return
    idx = (idx + 1) % abilities.size()
    selected_ability = abilities[idx]
    PlayerHud.update_ability_ui_select(selected_ability, true)

func prev_ability() -> void:
    var idx: int = abilities.find(selected_ability)
    if idx == -1:
        return
    idx = (idx - 1 + abilities.size()) % abilities.size()
    selected_ability = abilities[idx]
    PlayerHud.update_ability_ui_select(selected_ability, true)

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

func grapple_ability() -> void:
    # only allowed in [idle, walk]
    if player.fsm.current_state not in [player.fsm.idle, player.fsm.walk]:
        return

    player.fsm.change_state(player.fsm.fire_grapple)

func bow_ability() -> void:
    if player.arrow_count <= 0:
        return

    # only allowed in [idle, walk]
    if player.fsm.current_state not in [player.fsm.idle, player.fsm.walk]:
        return

    player.arrow_count -= 1
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
    var bomb: Node2D = BOMB.instantiate()
    player.add_sibling(bomb)
    bomb_instance = bomb

    PlayerManager.interact_handled = false
    var throwable: Throwable = bomb.get_node("Throwable")
    # start animation offset in seconds
    # todo: better ways like enter with event
    player.fsm.lift.start_anime_offset = 0.15
    throwable._on_player_interacted()
