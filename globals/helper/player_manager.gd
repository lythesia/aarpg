extends Node

signal PlayerRepositioned(player: Player)

const INVENTORY_DATA: InventoryData = preload("uid://ccgovctbimxdn")

var spawned: bool = false
var player: Player

func _ready() -> void:
    pass

func set_player(_player: Player) -> void:
    player = _player
    spawned = true

func get_player() -> Player:
    return player

func reparent_player_to_root() -> void:
    player.reparent.call_deferred(get_tree().root)

func reparent_player_to_scene(scene: Node) -> void:
    # player.reparent.call_deferred(scene)
    player.reparent(scene)

func set_player_global_position(position: Vector2) -> void:
    player.global_position = position
    PlayerRepositioned.emit(player)
