extends PointLight2D

@export var flicker_interval: float = 0.1

func _ready() -> void:
    flicker()

func flicker() -> void:
    energy = randf() * 0.1 + 0.9
    scale = Vector2(1, 1) * energy
    await get_tree().create_timer(
        flicker_interval * 0.8 + flicker_interval * randf_range(-0.2, 0.2)
    ).timeout
    flicker.call_deferred()
