@tool
class_name InventorySlotUI extends Button

const EQUIP_AUDIO: AudioStream = preload("uid://dfybcufblax1w")

@onready var texture: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var inventory_ui: InventoryUI = $".."

var slot_data: SlotData: set = set_slot_data

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    texture.texture = null
    label.text = ""
    focus_entered.connect(_on_focus_entered)
    focus_exited.connect(_on_focus_exited)
    pressed.connect(_on_pressed)

func set_slot_data(value: SlotData):
    slot_data = value
    if !value:
        texture.texture = null
        label.text = ""
    else:
        texture.texture = slot_data.item_data.icon
        if slot_data.item_data.item_type == ItemData.ItemType.EQUIPABLE:
            if slot_data.equipped:
                _set_slot_equipped(true)
                # fill equip slot ui
                match (slot_data.item_data as EquipableItemData).equip_type:
                    EquipableItemData.EquipType.WEAPON:
                        PauseMenu.equip_ui.fill_weapon_slot(self)
                    EquipableItemData.EquipType.ARMOR:
                        PauseMenu.equip_ui.fill_armor_slot(self)
                    EquipableItemData.EquipType.AMULET:
                        PauseMenu.equip_ui.fill_amulet_slot(self)
                    EquipableItemData.EquipType.RING:
                        PauseMenu.equip_ui.fill_ring_slot(self)
            else:
                _set_slot_equipped(false)
        else:
            label.text = str(slot_data.quantity)

func _on_focus_entered() -> void:
    if slot_data:
        inventory_ui.update_item_desc(slot_data.item_data)

func _on_focus_exited() -> void:
    inventory_ui.update_item_desc()

func _on_pressed() -> void:
    if slot_data and slot_data.item_data:
        if slot_data.item_data.use():
            if slot_data.item_data.item_type == ItemData.ItemType.EQUIPABLE:
                # toggle equip
                if !slot_data.equipped:
                    _set_slot_equipped(true)
                    PlayerManager.equip(self)
                    Audio.play_ui_audio(EQUIP_AUDIO)
                else:
                    _set_slot_equipped(false)
                    PlayerManager.unequip(self)
                PauseMenu.equip_ui.apply_delta_stats()
            else:
                slot_data.quantity -= 1
                # update quantity label in-place
                # check `slot_data` first coz `quantity -=` might trigger:
                # SlotData.changed -> _on_slot_changed: inventory_data.tres::slots[i] = null
                # -> InventoryData.changed -> _on_inventory_changed -> update_inventory:
                # slot_ui[i].slot_data = inventory_data.slots[i] = null
                # then here `slot_data` becomes null
                if slot_data and slot_data.quantity > 0:
                    label.text = str(slot_data.quantity)

func _set_slot_equipped(value: bool) -> void:
    if value:
        label.text = "E"
        slot_data.equipped = true
    else:
        label.text = ""
        slot_data.equipped = false
