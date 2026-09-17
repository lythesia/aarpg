@tool
class_name EquippableWeapon extends EquippableItem

func sprite_texture() -> Texture2D:
    return get_resource("sprite_texture") as Texture2D
