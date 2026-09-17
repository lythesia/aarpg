@tool
class_name EquipSlotUI extends Button

const ITEM_ATLAS: Texture2D = preload("uid://c848iq4xyimqx")

const WEAPON_TYPE_ID: String = PandoraCategories.PickupsSlotItemsEquippableCategories.WEAPON
const ARMOR_TYPE_ID: String = PandoraCategories.PickupsSlotItemsEquippableCategories.ARMOR
const AMULET_TYPE_ID: String = PandoraCategories.PickupsSlotItemsEquippableCategories.AMULET
const RING_TYPE_ID: String = PandoraCategories.PickupsSlotItemsEquippableCategories.RING

@export var equip_type: PandoraCategory:
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

func set_equip_type(value: PandoraCategory) -> void:
    equip_type = value
    # we must have `ready` check here, coz:
    # pandora's initialization is lazy, api.gd `_entity_backend` is created at `_enter_tree()`
    # while pause_menu is global and thus setter of this `@export` happens before `_enter_tree()`
    # so we must wait for the node to be ready before setting the texture
    # todo: the best way I think is contorl the loading sequence, do not put all singletons to
    # global
    if is_node_ready() and equip_type:
        _set_equip_type_texture()

func _set_equip_type_texture() -> void:
    if !texture_rect:
        texture_rect = $TextureRect

    var t: AtlasTexture = AtlasTexture.new()
    t.atlas = ITEM_ATLAS

    match equip_type.get_entity_id():
        WEAPON_TYPE_ID:
            t.region = Rect2(0, 0, 16, 16)
        ARMOR_TYPE_ID:
            t.region = Rect2(0, 16, 16, 16)
        AMULET_TYPE_ID:
            t.region = Rect2(16, 0, 16, 16)
        RING_TYPE_ID:
            t.region = Rect2(16, 16, 16, 16)

    texture_rect.texture = t

func set_slot_data(value: SlotData) -> void:
    if !value:
        # reset to default texture
        _set_equip_type_texture()
        return

    if value.item_data is not EquippableItem:
        return

    var equipable_data = value.item_data as EquippableItem
    if !equipable_data.is_category(equip_type.get_entity_id()):
        return

    texture_rect.texture = equipable_data.texture()

# everytime `slot_linked` changed, invoke `EquipUI.update_delta_stats()`
func _on_equipped(slot: InventorySlotUI) -> void:
    # fix: slot's equipment must match `equip_type`
    if slot.slot_data.item_data is not EquippableItem or \
        # I just don't know why cannot `get_category() == equip_type`
        !(slot.slot_data.item_data as EquippableItem).is_category(equip_type.get_entity_id()):
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
