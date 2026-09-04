class_name GearItemUI extends Button

@export_multiline var description: String

func _ready() -> void:
    focus_entered.connect(_on_focused)

func _on_focused() -> void:
    PauseMenu.inventory_ui.update_item_description_literal(description)
