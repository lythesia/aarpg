class_name SlotData extends SaveKitResource

@export var item_data: SlotItemData
@export var quantity: int = 0: set = set_quantity

func set_quantity(value: int) -> void:
    quantity = value
    if value <= 0:
        quantity = 0
        emit_changed()

#region save/load
func save_to_dict(_s: Serializer) -> Dictionary:
    return {
        "item_data": Pandora.serialize(item_data),
        "quantity": quantity,
    }

func load_from_dict(_d: Deserializer, data: Dictionary) -> void:
    item_data = Pandora.deserialize(data["item_data"]) as SlotItemData
    quantity = data.get("quantity", 0)
#endregion
