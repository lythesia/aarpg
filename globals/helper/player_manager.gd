extends Node

signal PlayerRepositioned(player: Player)
signal PlayerInteracted
signal PlayerLeveledUp

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
        player.atk += 1
        player.def += 1
        leveled_up = true

    if leveled_up:
        PlayerLeveledUp.emit()
        player.heal()
#endregion
