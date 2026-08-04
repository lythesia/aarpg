class_name BarriedDoor extends Node2D

@export var lever: PressurePlate
@export var audio_open: AudioStream
@export var audio_close: AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    lever.Activated.connect(open_door)
    lever.Deactivated.connect(close_door)
    if lever.is_active:
        animation_player.play("opened")

func open_door() -> void:
    animation_player.play("open")
    if audio_open:
        Audio.play_spatial_sound(audio_open, global_position)

func close_door() -> void:
    animation_player.play("close")
    if audio_close:
        Audio.play_spatial_sound(audio_close, global_position)
