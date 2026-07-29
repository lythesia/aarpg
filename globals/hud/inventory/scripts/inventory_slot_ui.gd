class_name InventorySlotUI extends Button

@onready var texture: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var inventory_ui: InventoryUI = $".."

var slot_data: SlotData: set = set_slot_data

func _ready() -> void:
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
        texture.texture = slot_data.item_data.texture
        label.text = str(slot_data.quantity)

func _on_focus_entered() -> void:
    if slot_data:
        inventory_ui.update_item_desc(slot_data.item_data)

func _on_focus_exited() -> void:
    inventory_ui.update_item_desc()

func _on_pressed() -> void:
    if slot_data and slot_data.item_data:
        if slot_data.item_data.use():
            slot_data.quantity -= 1
