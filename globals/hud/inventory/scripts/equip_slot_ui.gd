@tool
class_name EquipSlotUI extends Button

const ITEM_ATLAS: Texture2D = preload("uid://c848iq4xyimqx")

@export var equip_type: EquipableItemData.EquipType = EquipableItemData.EquipType.WEAPON:
    set = set_equip_type

@onready var texture_rect: TextureRect = $TextureRect
@onready var equip_ui: EquipUI = $".."

var slot_linked: InventorySlotUI

func _ready() -> void:
    _set_equip_type_texture()

    if Engine.is_editor_hint():
        return

    PlayerManager.PlayerEquipped.connect(_on_equipped)
    PlayerManager.PlayerUnequipped.connect(_on_unequipped)

func reset() -> void:
    slot_linked = null
    _set_equip_type_texture()

func set_equip_type(value: EquipableItemData.EquipType) -> void:
    equip_type = value
    _set_equip_type_texture()

func _set_equip_type_texture() -> void:
    if !texture_rect:
        texture_rect = $TextureRect

    var t: AtlasTexture = AtlasTexture.new()
    t.atlas = ITEM_ATLAS

    match equip_type:
        EquipableItemData.EquipType.WEAPON:
            t.region = Rect2(0, 0, 16, 16)
        EquipableItemData.EquipType.ARMOR:
            t.region = Rect2(0, 16, 16, 16)
        EquipableItemData.EquipType.AMULET:
            t.region = Rect2(16, 0, 16, 16)
        EquipableItemData.EquipType.RING:
            t.region = Rect2(16, 16, 16, 16)

    texture_rect.texture = t

func set_slot_data(value: SlotData) -> void:
    if !value:
        # reset to default texture
        _set_equip_type_texture()
        return

    if value.item_data.item_type != ItemData.ItemType.EQUIPABLE or value.item_data is not EquipableItemData:
        return

    var equipable_data = value.item_data as EquipableItemData
    if equipable_data.equip_type != equip_type:
        return

    texture_rect.texture = equipable_data.icon

# everytime `slot_linked` changed, invoke `EquipUI.update_delta_stats()`
func _on_equipped(slot: InventorySlotUI) -> void:
    # fix: slot's equipment must match `equip_type`
    if slot.slot_data.item_data.item_type != ItemData.ItemType.EQUIPABLE or \
        (slot.slot_data.item_data as EquipableItemData).equip_type != equip_type:
        return

    if !slot_linked:
        fill_slot(slot)
    elif slot_linked != slot:
        # unequip previous item
        slot_linked._set_slot_equipped(false)
        # equip new item
        fill_slot(slot)

func _on_unequipped(slot: InventorySlotUI) -> void:
    if slot and slot == slot_linked:
        fill_slot(null)

func fill_slot(slot: InventorySlotUI) -> void:
    slot_linked = slot
    if slot:
        set_slot_data(slot.slot_data)
    else:
        set_slot_data(null)
    equip_ui.update_delta_stats()
