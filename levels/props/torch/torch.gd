class_name Torch extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    # make torch flame random
    var anim_len: float = animation_player.current_animation_length
    var offset = anim_len * randf()
    animation_player.seek(offset)
