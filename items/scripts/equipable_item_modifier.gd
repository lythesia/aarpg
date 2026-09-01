class_name EquipableItemModifier extends Resource

enum Type {
    HP, ATK, DEF,
}

@export var type: Type
@export var value: int

func to_str() -> String:
    return "%s+%d" % [Type.keys()[type], value]
