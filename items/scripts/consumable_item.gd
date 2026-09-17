@tool
class_name ConsumableItem extends SlotItemData

func use() -> bool:
    var effects: Array = get_array("use_effects")
    if effects.is_empty():
        return false

    for effect in effects:
        if effect is ItemUseEffect:
            effect.use()
    return true
