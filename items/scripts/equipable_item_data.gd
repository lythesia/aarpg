class_name EquipableItemData extends ItemData

enum EquipType {
    WEAPON,
    ARMOR,
    AMULET,
    RING,
}

@export var equip_type: EquipType
@export var modifiers: Array[EquipableItemModifier] = []

func use() -> bool:
    # always allow equiping
    return true
