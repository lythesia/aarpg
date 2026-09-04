## todo: `ItemData` is not persisted into save, maybe we don't need `extend SaveKitResource`
class_name ItemData extends SaveKitResource

enum ItemType {
    ## will not add to slot, but keeping as score
    CURRENCY,

    ## usable items
    CONSUMABLE,

    ## other items
    OTHER,

    ## equipable items
    EQUIPABLE,
}

## item's name, use as uniq key
@export var name: String

@export var item_type: ItemType = ItemType.CONSUMABLE

## general description of the item
@export_multiline var description: String

## item's icon texture
@export var icon: Texture2D

## item's buy price
@export var buy_price: int = 10

## item's use effects
@export_category("Item Use Effects")
@export var effects: Array[ItemEffect] = []

func use() -> bool:
    match item_type:
        ItemType.CONSUMABLE: pass
        _: return false

    if effects.is_empty():
        return false

    for effect in effects:
        if effect:
            effect.use()

    return true
