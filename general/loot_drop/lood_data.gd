class_name LootData extends Resource

@export var item_scene: PackedScene
@export_range(0, 100, 1, "or_greater") var min_drop: int = 0
@export_range(0, 100, 1, "or_greater") var max_drop: int = 1
@export_range(0.0, 1.0, 0.1) var drop_rate: float = 1.0

func get_drop_count() -> int:
    if randf() < drop_rate:
        return randi_range(min_drop, max_drop)
    return 0
