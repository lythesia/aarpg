class_name EquipData extends SaveKitResource

## inventory size
@export var capacity: int = 4

## slots: [weapon, armor, amulet, ring]
@export var slots: Array[SlotData] = []

func _init() -> void:
    ensure_capacity()
    _connect_slots()

func ensure_capacity() -> void:
    slots.resize(capacity)

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

func clear() -> void:
    slots.clear()

    # re-init
    _init()

#region save/load
func load_from_dict(d: Deserializer, data: Dictionary) -> void:
    super(d, data)
    # re-connect slots
    _connect_slots()
#endregion
