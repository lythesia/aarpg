@tool
class_name PickableItemBase extends PandoraEntity

## used in item icon (in UI) and texture (in scene)
func texture() -> Texture2D:
    return get_resource("texture") as Texture2D
