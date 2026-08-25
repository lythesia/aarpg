extends Node

signal PlayerRepositioned(player: Player)
signal PlayerInteracted

var INVENTORY_DATA: InventoryData

var spawned: bool = false
var player: Player
var interact_handled: bool = false

func _ready() -> void:
    pass

func set_player(_player: Player) -> void:
    player = _player
    spawned = true

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

func gain_xp(xp: int) -> void:
    player.xp += xp
