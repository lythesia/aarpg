class_name ItemMagnet extends Area2D

@export var magnet_strength: float = 1.0

var items: Array[ItemPickup] = []
var speeds: Array[float] = []

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    # iterate backwards to remove items that are picked up
    for i in range(items.size() - 1, -1, -1):
        var item: ItemPickup = items[i]
        # check if item is picked up (it'll be queue-freed)
        if item:
            speeds[i] += magnet_strength * delta
            item.position += item.global_position.direction_to(global_position) * speeds[i]
        else:
            items.remove_at(i)
            speeds.remove_at(i)

func _on_area_entered(area: Area2D) -> void:
    if area.get_parent() is ItemPickup:
        var item: ItemPickup = area.get_parent()
        items.append(item)
        speeds.append(magnet_strength)
        # disable collision to make sure player picks it up
        item.set_physics_process(false)
