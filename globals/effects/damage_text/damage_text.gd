class_name DamageText extends Node2D

@onready var label: Label = $Label

var move_range: Vector2 = Vector2(10, -20)

func start(text: String, start_pos: Vector2) -> void:
    label.text = text
    global_position = start_pos

    # animate
    move_range.y *= randf_range(0.5, 1.5)
    move_range.x *= randf_range(-1.5, 1.5)

    var dur: float = randf_range(0.75, 1.25)

    var tween: Tween = create_tween().set_parallel(true)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUAD)
    # tween position
    tween.tween_property(self, "global_position", global_position + move_range, dur)
    # tween modulate
    tween.tween_property(self, "modulate:a", 0.0, dur).set_ease(Tween.EASE_IN)

    # free
    tween.chain().tween_callback(queue_free)
