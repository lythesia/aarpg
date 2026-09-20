class_name DeliverItemStep extends QuestStep

@export var item: SlotItemData
@export var quantity: int = 1
@export var to: PandoraHuman

func on_start() -> void:
    on_load()

func check_condition() -> bool:
    return is_completed

func on_load() -> void:
    PlayerManager.PlayerDeliveredItem.connect(_on_item_delivered)

func _on_item_delivered(_item: SlotItemData, _quantity: int, _to: PandoraHuman) -> void:
    if _item.is_same(item) and _quantity >= quantity and _to.is_same(to):
        is_completed = true
        Updated.emit()
