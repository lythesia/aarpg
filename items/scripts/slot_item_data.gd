## item that can be put in inventory slot
@tool
class_name SlotItemData extends PickableItemBase

func name() -> String:
    return get_string("name")

func description() -> String:
    return get_string("description")

func buy_price() -> int:
    return get_integer("buy_price")

func stackable() -> bool:
    return get_bool("stackable")

func is_same(other: SlotItemData) -> bool:
    var _is_instance: bool = is_instance()
    var _is_other_instance: bool = other.is_instance()

    if _is_instance and _is_other_instance:
        return get_entity_instance_id() == other.get_entity_instance_id() and get_entity_id() == other.get_entity_id()
    else:
        return get_entity_id() == other.get_entity_id()
