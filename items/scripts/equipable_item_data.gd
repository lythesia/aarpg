class_name EquipableItemData extends ItemData

enum EquipType {
    WEAPON,
    ARMOR,
    AMULET,
    RING,
}

@export var equip_type: EquipType
@export var modifiers: Array[EquipableItemModifier] = []
@export var sprite_texture: Texture

func use() -> bool:
    # always allow equiping
    return true

func atk() -> int:
    var val: int = 0
    for modifier in modifiers:
        if modifier.type == EquipableItemModifier.Type.ATK:
            val += modifier.value
    return val

func def() -> int:
    var val: int = 0
    for modifier in modifiers:
        if modifier.type == EquipableItemModifier.Type.DEF:
            val += modifier.value
    return val

func stats_description() -> String:
    return " ".join(modifiers.map(func(m: EquipableItemModifier) -> String: return m.to_str()))
