# direct parent of inventory slots
@tool
class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://d28ga647y5dsu")

@export var inventory_data: InventoryData:
    set(value):
        inventory_data = value
        update_configuration_warnings()

var last_focused_slot: int = 0

func _ready() -> void:
    # init all slots
    # clear dirty slots
    for c in get_children():
        c.queue_free()
    # create new slots
    for _i in inventory_data.capacity:
        var slot_ui: InventorySlotUI = INVENTORY_SLOT.instantiate()
        add_child(slot_ui)
        slot_ui.set_slot_data(null)
        # connect focus entered signal only once at init
        slot_ui.focus_entered.connect(_on_slot_focused)

    if Engine.is_editor_hint():
        return

    assert(inventory_data, "inventory_data is not set")
    PlayerManager.set_inventory_data(inventory_data)
    PauseMenu.PauseMenuShown.connect(_on_paused)
    PauseMenu.PauseMenuHidden.connect(_on_unpaused)
    connect_inventory_changed()

func update_inventory(force_focus: bool = false) -> void:
    for i in inventory_data.slots.size():
        var slot_ui: InventorySlotUI = get_child(i)
        slot_ui.slot_data = inventory_data.slots[i]
    if force_focus and inventory_data.slots.size() > 0:
        get_child(0).grab_focus()

func update_slot_focus() -> void:
    var slot_ui: InventorySlotUI = get_child(last_focused_slot)
    slot_ui.grab_focus()

# remember inventory is actually vec![null; cap], so calibrate here is to place non-null slots to the front
# with their order honored
func calibrate_inventory_data() -> void:
    for _i in inventory_data.slots.count(null):
        inventory_data.slots.erase(null)
    inventory_data.ensure_capacity()

func update_item_desc(item_data: ItemData = null) -> void:
    var text: String
    if item_data:
        if item_data.item_type == ItemData.ItemType.EQUIPABLE:
            var i: EquipableItemData = item_data as EquipableItemData
            text = "%s  %s" % [i.description, i.stats_str()]
        else:
            text = item_data.description
    else:
        text = ""
    PauseMenu.item_desc_label.text = text

func update_coin_label() -> void:
    var n: int = inventory_data.currencies.get("Coin", 0)
    PauseMenu.coin_label.text = str(n)

func _on_paused() -> void:
    update_inventory(true)
    update_slot_focus()
    update_coin_label()

    # connect during paused
    visibility_changed.connect(_on_visibility_changed)

func _on_unpaused() -> void:
    calibrate_inventory_data()

    # disconnect when unpaused
    visibility_changed.disconnect(_on_visibility_changed)

# connect only after inventory updated during paused
func _on_visibility_changed() -> void:
    if visible:
        update_slot_focus()

func _on_inventory_changed() -> void:
    # if not paused, we don't do any UI updates
    if !PauseMenu.is_paused:
        return

    update_inventory() # full update
    update_slot_focus()

func _on_slot_focused() -> void:
    for i in get_child_count():
        var slot_ui: InventorySlotUI = get_child(i)
        if slot_ui.has_focus():
            last_focused_slot = i
            return

## we need to manually reconnect instead of relying `_ready` coz
## PauseMenu is global autoload, `_ready` won't trigger again on
## scene (re)load
func connect_inventory_changed() -> void:
    inventory_data.changed.connect(_on_inventory_changed)

func _get_configuration_warnings() -> PackedStringArray:
    if !inventory_data:
        return ["inventory_data is required"]
    return []
