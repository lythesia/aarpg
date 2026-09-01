extends Node

signal PlayerRepositioned(player: Player)
signal PlayerInteracted
signal PlayerLeveledUp

signal PlayerEquipped(slot: InventorySlotUI)
signal PlayerUnequipped(slot: InventorySlotUI)
signal PlayerStatsUpdated

var INVENTORY_DATA: InventoryData

var spawned: bool = false
var player: Player
var interact_handled: bool = false

func _ready() -> void:
    pass

func set_player(_player: Player) -> void:
    player = _player
    spawned = true

func clear_player() -> void:
    if player:
        player.queue_free()
        player = null
        spawned = false

        INVENTORY_DATA.clear()
        QuestManager.clear_current_quests()
        PauseMenu.equip_ui.reset_equip_slots()

func set_inventory_data(_inventory_data: InventoryData) -> void:
    INVENTORY_DATA = _inventory_data

func get_player() -> Player:
    return player

func reparent_player_to_root() -> void:
    player.reparent.call_deferred(get_tree().root)

func reparent_player_to_scene(scene: Node) -> void:
    player.reparent(scene)

func set_player_global_position(position: Vector2) -> void:
    player.global_position = position
    PlayerRepositioned.emit(player)

func player_interact() -> void:
    # only one interactable can accquire this flag on `PlayerInteracted` shot
    interact_handled = false
    PlayerInteracted.emit()

func player_in_scene(scene: Node) -> bool:
    return scene.get_node_or_null("Player") == player

#region player_stats
func gain_xp(xp: int) -> void:
    if player:
        player.xp += xp
        # try level up
        level_up()
    else:
        printerr("no player instance!")

const LEVEL_UP_XP: Array[int] = [
    0,
    50, # lv.1 -> lv.2
    100,
    200,
    320,
    500,
    720,
    1000,
    1400,
    2000, # lv.9 -> lv.10
]

func level_up() -> void:
    var leveled_up: bool = false
    while player.level < LEVEL_UP_XP.size() and player.xp >= LEVEL_UP_XP[player.level]:
        player.level += 1
        player.base_atk += 1
        player.base_def += 1
        leveled_up = true

    if leveled_up:
        PlayerLeveledUp.emit()
        player.heal()

func equip(slot: InventorySlotUI) -> void:
    PlayerEquipped.emit(slot)

func unequip(slot: InventorySlotUI) -> void:
    PlayerUnequipped.emit(slot)

func apply_delta_stats(atk_delta: int, def_delta: int) -> void:
    var _atk = player.base_atk + atk_delta
    var _def = player.base_def + def_delta
    var updated: bool = false
    if _atk != player.atk:
        player.atk = _atk
        updated = true
    if _def != player.def:
        player.def = _def
        updated = true
    if updated:
        PlayerStatsUpdated.emit()
#endregion

func apply_weapon_sprite(item: EquipableItemData) -> void:
    player.sprite.update_weapon_sprite(item)
