class_name SlotData extends SaveKitResource

@export var item_data: ItemData
@export var quantity: int = 0: set = set_quantity
@export var equipped: bool = false

func set_quantity(value: int) -> void:
    quantity = value
    if value <= 0:
        quantity = 0
        emit_changed()

#region save/load
func save_to_dict(_s: Serializer) -> Dictionary:
    return {
        "item_data": item_data.resource_path,
        "quantity": quantity,
        "equipped": equipped,
    }

func load_from_dict(_d: Deserializer, data: Dictionary) -> void:
    item_data = load(data["item_data"])
    quantity = data.get("quantity", 0)
    equipped = data.get("equipped", false)
#endregion
