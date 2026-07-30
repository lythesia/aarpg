class_name InventoryData extends SaveKitResource

## inventory size
@export var capacity: int = 18

## slots in inventory
@export var slots: Array[SlotData] = []

func _init() -> void:
    ensure_capacity()
    _connect_slots()

func ensure_capacity() -> void:
    slots.resize(capacity)

func add_item(item_data: ItemData, quantity: int = 1) -> bool:
    # 1. try to stack
    for slot in slots:
        if slot and slot.item_data == item_data:
            slot.quantity += quantity
            return true

    # 2. try put into empty slot
    for i in slots.size():
        if !slots[i]:
            var slot: SlotData = SlotData.new()
            slot.item_data = item_data
            slot.quantity = quantity
            slots[i] = slot
            # new slot should also be connected
            slot.changed.connect(_on_slot_changed)
            return true

    # 3. no slots, inventory is full
    print("inventory is full")
    return false

func _connect_slots():
    for slot in slots:
        if !slot: continue
        slot.changed.connect(_on_slot_changed)

# actually it means item's quantity changed to 0 now
func _on_slot_changed() -> void:
    for i in slots.size():
        var slot = slots[i]
        if slot and slot.quantity <= 0:
            # disconnect this slot first
            slot.changed.disconnect(_on_slot_changed)
            # make that slot empty in ui
            slots[i] = null
            emit_changed()

#region save/load
func load_from_dict(d: Deserializer, data: Dictionary) -> void:
    super(d, data)
    # re-connect slots
    _connect_slots()
#endregion
