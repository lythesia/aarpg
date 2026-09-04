class_name PlayerSprite extends Sprite2D

const FRAME_COUNT: int = 128

@onready var weapon_below_sprite: Sprite2D = $WeaponBelow
@onready var weapon_above_sprite: Sprite2D = $WeaponAbove

func _ready() -> void:
    PlayerManager.PlayerEquipped.connect(_on_equipment_changed)

func _process(_delta: float) -> void:
    weapon_below_sprite.frame = frame # 1st half
    weapon_above_sprite.frame = frame + FRAME_COUNT # 2nd half

func _on_equipment_changed(slot: InventorySlotUI) -> void:
    var i: EquipableItemData = slot.slot_data.item_data
    match i.equip_type:
        EquipableItemData.EquipType.WEAPON:
            update_weapon_sprite(i)
        _: # ignore others for now (like armor)
            pass

func update_weapon_sprite(item: EquipableItemData) -> void:
    weapon_below_sprite.texture = item.sprite_texture
    weapon_above_sprite.texture = item.sprite_texture

func ghost(dur: float = 0.2) -> void:
    var effect: Node2D = Node2D.new()
    var player: Node2D = owner
    player.add_sibling(effect) # place it same level as player
    # re-order effect to avoid it comes top of player coz its z-index = 1 which is same with player
    effect.get_parent().move_child(effect, 0)
    effect.z_index = 1
    effect.global_position = player.global_position
    effect.modulate = Color(0.0, 1.5, 0.95, 0.75)

    var sprite_copy: Sprite2D = _duplicate_sprites()
    effect.add_child(sprite_copy)

    # fade
    var t: Tween = create_tween()
    t.set_ease(Tween.EASE_OUT)
    t.tween_property(effect, "modulate", Color.TRANSPARENT, dur)
    t.chain().tween_callback(effect.queue_free) # Will run after tween finished.

func _duplicate_sprites() -> Sprite2D:
    var sprite_copy: Sprite2D = duplicate(Node.DUPLICATE_USE_INSTANTIATION)
    var weapon_below_copy: Sprite2D = weapon_below_sprite.duplicate()
    var weapon_above_copy: Sprite2D = weapon_above_sprite.duplicate()
    sprite_copy.add_child(weapon_below_copy)
    sprite_copy.add_child(weapon_above_copy)
    return sprite_copy
