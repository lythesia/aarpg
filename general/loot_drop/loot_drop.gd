@icon("res://public/icons/loot_drop.svg")
class_name LootDropper extends Marker2D

@export var items: Array[LootData]

func _ready() -> void:
    if owner is Enemy:
        owner.WasKilled.connect(self._drop_loot)

func _drop_loot() -> void:
    for item in items:
        if !item || !item.item_scene: continue
        for j in item.get_drop_count():
            var drop: ItemPickup = item.item_scene.instantiate()
            owner.add_sibling.call_deferred(drop)
            drop.global_position = global_position
