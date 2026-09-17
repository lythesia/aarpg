class_name InventoryData extends SaveKitResource

signal GainItem(item_data: SlotItemData, quantity: int)

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
        if slot and slot.item_data.name() == name:
            return slot
    return null

func ensure_capacity() -> void:
    slots.resize(capacity)

func add_item(item_data: SlotItemData, quantity: int = 1) -> bool:
    var ok: bool = false
    if item_data is EquippableItem:
        # new instance
        var instance: EquippableItem = item_data.instantiate() as EquippableItem
        ok = add_equipable(instance)
    elif item_data.stackable():
        ok = add_stackable(item_data, quantity)
    else:
        ok = add_unstackable(item_data, quantity)

    if ok:
        GainItem.emit(item_data, quantity)
    return ok

func add_stackable(item_data: SlotItemData, quantity: int = 1) -> bool:
    # 1. try to stack
    for slot in slots:
        if slot and slot.item_data.is_same(item_data):
            slot.quantity += quantity
            return true

    # 2. try to put into empty slot
    return _put_into_empty_slot(item_data, quantity)

func add_currency(item_data: CurrencyItemData, quantity: int) -> bool:
    currencies.get_or_add(item_data.name(), 0 as int)
    currencies[item_data.name()] += quantity
    return true

func add_equipable(instance: EquippableItem) -> bool:
    return _put_into_empty_slot(instance)

func add_ammo(item_data: AmmoItemData, quantity: int) -> bool:
    var player: Player = PlayerManager.get_player()
    var _id: String = item_data.get_entity_id()
    match _id:
        AmmoIds.ARROWS:
            if player.abilities.has_ability(PlayerAbilities.Ability.BOW):
                player.arrow_count += quantity
        AmmoIds.BOMBS:
            if player.abilities.has_ability(PlayerAbilities.Ability.BOMB):
                player.bomb_count += quantity
        _: pass
    return true

func add_unstackable(item_data: SlotItemData, quantity: int = 1) -> bool:
    var all_ok: Array[bool] = []
    for _q in quantity:
        if _put_into_empty_slot(item_data):
            all_ok.append(true)
        else:
            break
    return all_ok.all(func(ok: bool) -> bool: return ok)

func _put_into_empty_slot(item_data: SlotItemData, quantity: int = 1) -> bool:
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

func consume_item(item: SlotItemData, count: int = 1) -> bool:
    for slot in slots:
        if slot and slot.item_data.is_same(item) and slot.quantity >= count:
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

func get_item_hold_quantity(item: SlotItemData) -> int:
    for slot in slots:
        if slot and slot.item_data.is_same(item):
            return slot.quantity
    return 0

func get_coin_amount() -> int:
    return currencies.get("Coin", 0) as int

func consume_coin(amount: int) -> void:
    currencies["Coin"] -= amount

#region save/load
func load_from_dict(d: Deserializer, data: Dictionary) -> void:
    super(d, data)
    # re-connect slots on load
    _connect_slots()
#endregion

func stats_from_equipments() -> Dictionary:
    # go through equip slots and apply delta stats
    var atk_delta: int = 0
    var def_delta: int = 0
    for slot in slots:
        if slot and slot.item_data is EquippableItem:
            var e: EquippableItem = slot.item_data
            if !e.is_equipped():
                continue
            atk_delta += e.atk()
            def_delta += e.def()
            if e is EquippableWeapon:
                PlayerManager.apply_weapon_sprite(e as EquippableWeapon)
    return {"atk_delta": atk_delta, "def_delta": def_delta}
