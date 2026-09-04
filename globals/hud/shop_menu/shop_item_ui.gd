class_name ShopItemUI extends Button

@onready var texture: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var price_label: Label = $PriceLabel

var item: ItemData

func setup_item(item_data: ItemData) -> void:
    item = item_data
    texture.texture = item.icon
    label.text = item.name
    price_label.text = str(item.buy_price)
