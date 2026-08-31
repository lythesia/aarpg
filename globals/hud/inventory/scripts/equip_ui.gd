class_name EquipUI extends Control

@onready var slot_weapon: EquipSlotUI = $SlotWeapon
@onready var slot_armor: EquipSlotUI = $SlotArmor
@onready var slot_amulet: EquipSlotUI = $SlotAmulet
@onready var slot_ring: EquipSlotUI = $SlotRing

# update equip slots every time when it shows
func reset_equip_slots() -> void:
    slot_weapon.reset()
    slot_armor.reset()
    slot_amulet.reset()
    slot_ring.reset()
