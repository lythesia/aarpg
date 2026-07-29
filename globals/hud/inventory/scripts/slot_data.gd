class_name SlotData extends SaveKitResource

@export var item_data: ItemData
@export var quantity: int = 0: set = set_quantity

func set_quantity(value: int) -> void:
    quantity = value
    if value <= 0:
        quantity = 0
        emit_changed()
