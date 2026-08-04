class_name LockedDoor extends Node2D

@export var key: ItemData
@export var unlock_audio: AudioStream
@export var lock_audio: AudioStream
@export var persistent_key: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $InteractArea

var is_open: bool = false

func _ready() -> void:
    if persistent_key and WorldState.get_kv(persistent_key):
        is_open = true
        animation_player.play("opened")
    else:
        interact_area.area_entered.connect(_on_area_entered)
        interact_area.area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
    if !is_open and area is PlayerInteraction:
        PlayerManager.PlayerInteracted.connect(_on_player_interacted)

func _on_area_exited(area: Area2D) -> void:
    if !is_open and area is PlayerInteraction:
        PlayerManager.PlayerInteracted.disconnect(_on_player_interacted)

func _on_player_interacted() -> void:
    if is_open or !key: return

    if PlayerManager.INVENTORY_DATA.use_item(key):
        animation_player.play("opened")
        if unlock_audio:
            Audio.play_spatial_sound(unlock_audio, global_position)
        is_open = true

        if persistent_key:
            WorldState.add_kv(persistent_key, true)
    else:
        if lock_audio:
            Audio.play_spatial_sound(lock_audio, global_position)
