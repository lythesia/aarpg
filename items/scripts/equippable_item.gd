@tool
class_name EquippableItem extends SlotItemData

func atk() -> int:
    return get_integer("atk")

func def() -> int:
    return get_integer("def")

func is_equipped() -> bool:
    return get_bool("is_equipped")

func set_is_equipped(value: bool) -> void:
    set_bool("is_equipped", value)

## non-property

func stats_description() -> String:
    var vs: Array[String] = []
    var _atk: int = atk()
    var _def: int = def()
    if _atk > 0:
        vs.append("ATK+%d" % _atk)
    if _def > 0:
        vs.append("DEF+%d" % _def)
    return " ".join(vs)
