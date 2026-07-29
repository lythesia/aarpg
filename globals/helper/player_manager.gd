extends Node

const INVENTORY_DATA: InventoryData = preload("uid://ccgovctbimxdn")

func _ready() -> void:
    pass

func get_player() -> Player:
    return get_tree().get_first_node_in_group("Player")
