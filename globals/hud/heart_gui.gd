class_name HeartGui extends Control

@onready var sprite: Sprite2D = $Sprite2D

# 0: empty, 1: half, 2: full
const FRAME_MAX: int = 2
var heart_frame: int = FRAME_MAX:
    set(value):
        heart_frame = clamp(value, 0, FRAME_MAX)
        update_sprite()

func update_sprite():
    sprite.frame = heart_frame
