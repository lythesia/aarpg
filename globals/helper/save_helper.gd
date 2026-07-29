extends Node

const SAVE_SLOTS: Array[String] = [
    "slot_01",
    "slot_02",
    "slot_03",
]

var current_slot: int = 0

func _ready() -> void:
    SaveManager.save_file_extension = ".json"
    SaveManager.after_load.connect(_on_after_load)

func save():
    SaveManager.save_game([SAVE_SLOTS[current_slot]])

func load():
    SaveManager.load_game([SAVE_SLOTS[current_slot]])

func switch_slot(slot: int):
    current_slot = slot

func _on_after_load() -> void:
    SceneHelper.load_scene_and_setup_player(SceneHelper.scene_to_load)
