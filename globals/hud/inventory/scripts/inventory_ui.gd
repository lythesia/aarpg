# direct parent of inventory slots
class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://d28ga647y5dsu")

@export var capacity: int = 18
@export var data: InventoryData

@onready var item_desc_label: Label = $"../../ItemDesc"

func _ready() -> void:
    PauseMenu.PauseMenuShown.connect(update_inventory)
    PauseMenu.PauseMenuHidden.connect(clear_inventory)

func update_inventory() -> void:
    for i in capacity:
        var slot: InventorySlotUI = INVENTORY_SLOT.instantiate()
        add_child(slot)
        if i < data.slots.size():
            slot.slot_data = data.slots[i]

    if data.slots.size() > 0:
        get_child(0).grab_focus()

func clear_inventory() -> void:
    for c in get_children():
        c.queue_free()

func update_item_desc(item_data: ItemData = null) -> void:
    item_desc_label.text = item_data.description if item_data else ""
