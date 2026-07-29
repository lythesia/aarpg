# direct parent of inventory slots
class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://d28ga647y5dsu")

@export var inventory_data: InventoryData = InventoryData.new()

@onready var item_desc_label: Label = $"../../ItemDesc"

var last_focused_slot: int = 0

func _ready() -> void:
    PauseMenu.PauseMenuShown.connect(_on_paused)
    PauseMenu.PauseMenuHidden.connect(_on_unpaused)
    inventory_data.changed.connect(_on_inventory_changed)

func update_inventory() -> void:
    for slot in inventory_data.slots:
        var slot_ui: InventorySlotUI = INVENTORY_SLOT.instantiate()
        ## IMPORTANT! `add_child` first to let `onready` vars be initialized
        add_child(slot_ui)
        slot_ui.slot_data = slot
        slot_ui.focus_entered.connect(_on_slot_focused)

func update_slot_focus() -> void:
    var slot_ui: InventorySlotUI = get_child(last_focused_slot)
    slot_ui.grab_focus()

func clear_inventory() -> void:
    for c in get_children():
        c.queue_free()

# remember inventory is actually vec![null; cap], so calibrate here is to place non-null slots to the front
# with their order honored
func calibrate_inventory_data() -> void:
    for _i in inventory_data.slots.count(null):
        inventory_data.slots.erase(null)
    inventory_data.ensure_capacity()

func update_item_desc(item_data: ItemData = null) -> void:
    item_desc_label.text = item_data.description if item_data else ""

func _on_paused() -> void:
    update_inventory()
    await get_tree().process_frame
    update_slot_focus()

func _on_unpaused() -> void:
    clear_inventory()
    calibrate_inventory_data()

func _on_inventory_changed() -> void:
    clear_inventory()
    update_inventory()
    # check notion page for why call_deferred doesn't work here
    await get_tree().process_frame
    update_slot_focus()

func _on_slot_focused() -> void:
    for i in get_child_count():
        var slot_ui: InventorySlotUI = get_child(i)
        if slot_ui.has_focus():
            last_focused_slot = i
            return
