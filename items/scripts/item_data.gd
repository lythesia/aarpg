class_name ItemData extends SaveKitResource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D

func save_to_dict(s: Serializer) -> Dictionary:
    var dict: Dictionary = super(s)
    dict.erase("texture")
    return dict
