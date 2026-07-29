class_name ItemData extends SaveKitResource

## item's name, use as uniq key
@export var name: String

## general description of the item
@export_multiline var description: String

## item's texture
@export var texture: Texture2D

## item's use effects
@export_category("Item Use Effects")
@export var effects: Array[ItemEffect] = []

func use() -> bool:
    if effects.is_empty():
        return false

    for effect in effects:
        if effect:
            effect.use()

    return true

func save_to_dict(s: Serializer) -> Dictionary:
    var dict: Dictionary = super(s)
    dict.erase("texture")
    return dict
