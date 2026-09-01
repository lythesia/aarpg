class_name EquipUI extends Control

@onready var slot_weapon: EquipSlotUI = $SlotWeapon
@onready var slot_armor: EquipSlotUI = $SlotArmor
@onready var slot_amulet: EquipSlotUI = $SlotAmulet
@onready var slot_ring: EquipSlotUI = $SlotRing

# @onready var
@onready var atk_delta_label: Label = $"../../HBoxContainer/AtkDeltaLabel"
@onready var def_delta_label: Label = $"../../HBoxContainer2/DefDeltaLabel"

# reset on player clear
func reset_equip_slots() -> void:
    # reset slot & texture
    slot_weapon.reset()
    slot_armor.reset()
    slot_amulet.reset()
    slot_ring.reset()

    # reset delta label
    atk_delta_label.text = "+0"
    def_delta_label.text = "+0"

func update_delta_stats() -> void:
    var stats: Dictionary = _gather_equip_stats()
    atk_delta_label.text = "+%d" % stats["atk"]
    def_delta_label.text = "+%d" % stats["def"]

# todo: can we have MVC like mechanism to do ui & stats updates?
func apply_delta_stats() -> void:
    var stats: Dictionary = _gather_equip_stats()
    PlayerManager.apply_delta_stats(stats["atk"], stats["def"])

func _gather_equip_stats() -> Dictionary:
    var atk_delta: int = 0
    var def_delta: int = 0

    for slot in [slot_weapon, slot_armor, slot_amulet, slot_ring]:
        var stats: Dictionary = _get_equip_stats(slot)
        atk_delta += stats["atk"]
        def_delta += stats["def"]

    return {"atk": atk_delta, "def": def_delta}

func _get_equip_stats(slot: EquipSlotUI) -> Dictionary:
    var atk: int = 0
    var def: int = 0
    if slot and slot.slot_linked and \
        slot.slot_linked.slot_data and \
        slot.slot_linked.slot_data.item_data:
        var e: EquipableItemData = slot.slot_linked.slot_data.item_data as EquipableItemData
        for m in e.modifiers:
            match m.type:
                EquipableItemModifier.Type.ATK:
                    atk += m.value
                EquipableItemModifier.Type.DEF:
                    def += m.value
    return {"atk": atk, "def": def}

func fill_weapon_slot(slot: InventorySlotUI) -> void:
    slot_weapon.fill_slot(slot)

func fill_armor_slot(slot: InventorySlotUI) -> void:
    slot_armor.fill_slot(slot)

func fill_amulet_slot(slot: InventorySlotUI) -> void:
    slot_amulet.fill_slot(slot)

func fill_ring_slot(slot: InventorySlotUI) -> void:
    slot_ring.fill_slot(slot)
