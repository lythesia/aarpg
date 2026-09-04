class_name InventoryData extends SaveKitResource

signal GainItem(item_data: ItemData, quantity: int)

## inventory size
@export var capacity: int = 24

## slots in inventory
@export var slots: Array[SlotData] = []

## currency-like, not occupying slot
@export var currencies: Dictionary = {}

func _init() -> void:
    ensure_capacity()
    _connect_slots()

func get_slot_by_name(name: String) -> SlotData:
    for slot in slots:
        if slot and slot.item_data.name == name:
            return slot
    return null

func ensure_capacity() -> void:
    slots.resize(capacity)

func add_item(item_data: ItemData, quantity: int = 1) -> bool:
    var ok: bool = false
    match item_data.item_type:
        ItemData.ItemType.CURRENCY:
            ok = _add_currency(item_data, quantity)
        ItemData.ItemType.EQUIPABLE:
            ok = _add_equipable(item_data)
        _:
            ok = _add_consumable(item_data, quantity)
    if ok:
        GainItem.emit(item_data, quantity)
    return ok

func _add_consumable(item_data: ItemData, quantity: int = 1) -> bool:
    # 1. try to stack
    for slot in slots:
        if slot and slot.item_data == item_data:
            slot.quantity += quantity
            return true

    # 2. try to put into empty slot
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

func _add_currency(item_data: ItemData, quantity: int) -> bool:
    currencies.get_or_add(item_data.name, 0 as int)
    currencies[item_data.name] += quantity
    return true

func _add_equipable(item_data: ItemData) -> bool:
    # try to put into empty slot
    for i in slots.size():
        if !slots[i]:
            var slot: SlotData = SlotData.new()
            slot.item_data = item_data
            slot.quantity = 1
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

func consume_item(item: ItemData, count: int = 1) -> bool:
    for slot in slots:
        if slot and slot.item_data == item and slot.quantity >= count:
            slot.quantity -= count
            return true
    return false

func clear() -> void:
    # clear items
    slots.clear()

    # clear currencies
    currencies.clear()

    # re-init
    _init()

func swap_slots_by_index(i: int, j: int) -> void:
    var t: SlotData = slots[i]
    slots[i] = slots[j]
    slots[j] = t
    emit_changed()

func get_item_hold_quantity(item: ItemData) -> int:
    for slot in slots:
        if slot and slot.item_data == item:
            return slot.quantity
    return 0

func get_coin_amount() -> int:
    return currencies.get("Coin", 0) as int

func consume_coin(amount: int) -> void:
    currencies["Coin"] -= amount

#region save/load
func load_from_dict(d: Deserializer, data: Dictionary) -> void:
    super(d, data)
    # go through equip slots and apply delta stats
    var atk_delta: int = 0
    var def_delta: int = 0
    for slot in slots:
        if slot and slot.item_data.item_type == ItemData.ItemType.EQUIPABLE and slot.equipped:
            var e: EquipableItemData = slot.item_data
            atk_delta += e.atk()
            def_delta += e.def()
            match e.equip_type:
                EquipableItemData.EquipType.WEAPON:
                    PlayerManager.apply_weapon_sprite(e)
                _: pass
    PlayerManager.apply_delta_stats(atk_delta, def_delta)
    # re-connect slots
    _connect_slots()
#endregion
