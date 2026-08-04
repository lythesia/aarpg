@tool
class_name ItemDropper extends Marker2D

@export var item: ItemData: set = _set_item
@export var drop_audio: AudioStream
@export var pickup_audio: AudioStream
@export var persistent_key: String

@onready var sprite: Sprite2D = $Sprite2D

var has_dropped: bool = false

const PICKUP: PackedScene = preload("uid://bjjhsf5oolhc4")

func _ready() -> void:
    if Engine.is_editor_hint():
        _update_texture()
        return

    sprite.visible = false
    if persistent_key and WorldState.get_kv(persistent_key):
        has_dropped = true
        return

func drop_item() -> void:
    if has_dropped or !item: return

    var drop: ItemDropPickup = PICKUP.instantiate()
    drop.item_data = item
    drop.pickup_audio = pickup_audio
    drop.texture_type = ItemPickup.TextureType.ITEM_DATA
    add_child(drop)
    if drop_audio:
        Audio.play_spatial_sound(drop_audio, global_position)
    if persistent_key:
        WorldState.add_kv(persistent_key, true)
    has_dropped = true

func _set_item(value: ItemData) -> void:
    item = value
    _update_texture()

func _update_texture() -> void:
    if Engine.is_editor_hint():
        if sprite and item:
            sprite.texture = item.icon
