extends Node2D

@export var persistent_key: String = "d04_boss"

@onready var dark_wizard: Enemy = %DarkWizard
@onready var base_layer: TileMapLayer = %BaseDungeon
@onready var locked_layer: TileMapLayer = %BaseLockedDungeon

func _ready() -> void:
    if WorldState.has_kv(persistent_key) and WorldState.get_kv(persistent_key):
        _unlock_room()
        queue_free()
    else:
        _lock_room()
        dark_wizard.tree_exited.connect(_on_defeated)

func _on_defeated() -> void:
    WorldState.add_kv(persistent_key, true)
    _unlock_room()
    queue_free()

func _lock_room() -> void:
    base_layer.enabled = false
    locked_layer.enabled = true

func _unlock_room() -> void:
    base_layer.enabled = true
    locked_layer.enabled = false
