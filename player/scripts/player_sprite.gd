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
