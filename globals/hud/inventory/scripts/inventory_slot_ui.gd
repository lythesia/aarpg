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

func set_slot_data(value: SlotData):
    if !value:
        return

    slot_data = value
    texture.texture = slot_data.item_data.texture
    label.text = str(slot_data.quantity)

func _on_focus_entered() -> void:
    if slot_data:
        inventory_ui.update_item_desc(slot_data.item_data)

func _on_focus_exited() -> void:
    inventory_ui.update_item_desc()
