@tool
class_name InventorySlotUI extends Button

const EQUIP_AUDIO: AudioStream = preload("uid://dfybcufblax1w")

@onready var texture: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var inventory_ui: InventoryUI = $".."

var slot_data: SlotData: set = set_slot_data
var click_pos: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_texture: Control
var drag_threshold: float = 16 # min drag distance to tell user's dragging or not

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    texture.texture = null
    label.text = ""
    focus_entered.connect(_on_focus_entered)
    focus_exited.connect(_on_focus_exited)
    pressed.connect(_on_pressed)
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

func _process(_delta: float) -> void:
    if is_dragging and drag_texture:
        drag_texture.position = get_local_mouse_position() - texture.size / 2 # make it centered
        if drag_threshold_reached():
            drag_texture.modulate.a = 0.5
        else:
            drag_texture.modulate.a = 0

func drag_threshold_reached() -> bool:
    return get_global_mouse_position().distance_to(click_pos) > drag_threshold

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
        inventory_ui.update_item_description(slot_data.item_data)

func _on_focus_exited() -> void:
    inventory_ui.update_item_description()

func _on_pressed() -> void:
    if slot_data and slot_data.item_data and !drag_threshold_reached():
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

func _on_button_down() -> void:
    click_pos = get_global_mouse_position()
    is_dragging = true
    drag_texture = texture.duplicate()
    drag_texture.z_index = 10
    # stop `drag_texture` from receiving mouse events and consume it, while pass it to slots beneath
    # check notions: "Grid Buttons Drag & Drop issue"
    drag_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(drag_texture)

func _on_button_up() -> void:
    is_dragging = false
    if drag_texture:
        drag_texture.free()
