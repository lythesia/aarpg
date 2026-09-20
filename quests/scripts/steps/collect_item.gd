class_name CollectItemStep extends QuestStep

@export var item: SlotItemData
@export var quantity: int = 1

var collected: int = 0

func on_start() -> void:
    on_load()
    check_condition()

# it happens at:
# 1. quest start or progress updates
# 2. item add or remove
# there's case for LIVE that:
# 1. collect conditino met, is_completed = true
# 2. in final step: hand it over to npc
# 3. item_removed makes is_completed = false
# 4. so quest cannot be completed
# we can make final step and complete as atomic, and complete(force)?
func check_condition() -> bool:
    match complete_mode:
        CompleteMode.LATCH:
            if is_completed:
                return true
            if collected >= quantity:
                is_completed = true
                Updated.emit()
                return true
            else:
                return false
        CompleteMode.LIVE:
            if collected >= quantity:
                is_completed = true
                Updated.emit()
                return true
            else:
                is_completed = false
                return false
        _:
            return false

func on_load() -> void:
    PlayerManager.INVENTORY_DATA.ItemAdded.connect(_on_item_added)
    PlayerManager.INVENTORY_DATA.ItemRemoved.connect(_on_item_removed)
    collected = PlayerManager.INVENTORY_DATA.get_item_hold_quantity(item)

func _on_item_added(item_data: SlotItemData, _quantity: int) -> void:
    if !item_data.is_same(item):
        return

    match complete_mode:
        # no changes if completed
        CompleteMode.LATCH:
            if is_completed: return
            collected += _quantity
        # always update collected
        CompleteMode.LIVE:
            collected += _quantity

    check_condition()

func _on_item_removed(item_data: SlotItemData, _quantity: int) -> void:
    if !item_data.is_same(item):
        return

    match complete_mode:
        # no changes if completed
        CompleteMode.LATCH:
            if is_completed: return
            collected -= _quantity
        # always update collected
        CompleteMode.LIVE:
            collected -= _quantity

    check_condition()
