class_name ShopItemUI extends Button

@onready var texture: TextureRect = $HBoxContainer/TextureRect
@onready var label: Label = $HBoxContainer/Label
@onready var price_label: Label = $HBoxContainer/PriceLabel

var item: SlotItemData

func setup_item(item_data: SlotItemData) -> void:
    item = item_data
    texture.texture = item.texture()
    label.text = item.name()
    price_label.text = str(item.buy_price())
