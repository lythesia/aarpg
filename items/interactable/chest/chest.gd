@tool
class_name Chest extends Node2D

@export var item_data: ItemData
@export var quantity: int = 1
@export var persistent_key: String

@onready var sprite: Sprite2D = $Sprite2D
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var item_quantity_label: Label = $ItemSprite/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $Area2D

var is_open: bool = false

func _ready() -> void:
    _update_texture()
    _update_quantity_label()

    if Engine.is_editor_hint():
        return

    if WorldState.has_kv(persistent_key) and WorldState.get_kv(persistent_key):
        _set_chest_open()
    else:
        interact_area.area_entered.connect(_on_area_entered)
        interact_area.area_exited.connect(_on_area_exited)

func _set_chest_open() -> void:
    sprite.frame = 1
    # free un-needed nodes
    item_sprite.queue_free()
    item_quantity_label.queue_free()
    interact_area.queue_free()
    # update flag
    is_open = true

func _set_item_data(value: ItemData):
    item_data = value
    _update_texture()

func _update_texture():
    if item_sprite and item_data:
        item_sprite.texture = item_data.icon

func _set_quantity(value: int):
    quantity = value
    _update_quantity_label()

func _update_quantity_label():
    if quantity > 1:
        item_quantity_label.text = "x %d" % quantity
    else:
        item_quantity_label.text = ""

func _on_area_entered(_area: Area2D) -> void:
    PlayerManager.PlayerInteracted.connect(_on_player_interacted)
    pass

func _on_area_exited(_area: Area2D) -> void:
    PlayerManager.PlayerInteracted.disconnect(_on_player_interacted)

func _on_player_interacted() -> void:
    if is_open: return

    is_open = true
    WorldState.add_kv(persistent_key, true)
    animation_player.play("open")
    if item_data and quantity > 0:
        PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
    else:
        printerr("No items in chest")
