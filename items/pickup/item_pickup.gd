@tool
class_name ItemPickup extends Node2D

@export var item_data: ItemData: set = _set_item_data
@export var pickup_audio: AudioStream

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
    y_sort_enabled = true
    _update_texture()
    if Engine.is_editor_hint():
        return

    area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Player and item_data:
        if PlayerManager.INVENTORY_DATA.add_item(item_data):
            item_picked_up(body)

func _set_item_data(value: ItemData) -> void:
    item_data = value
    _update_texture()

func _update_texture() -> void:
    if item_data and sprite:
        sprite.texture = item_data.texture

func item_picked_up(player: Player) -> void:
    area.body_entered.disconnect(_on_body_entered)
    if pickup_audio:
        Audio.play_spatial_sound(pickup_audio, global_position)
    play_pickup_animation(player)

func play_pickup_animation(player: Node2D) -> void:
    # 1. Disable collisions to prevent multiple pickup triggers
    area.set_deferred("monitoring", false)

    # 2. Fix Top-Down sorting issue: Force item to render on top of the player
    z_as_relative = false # Disconnect from parent's Y-Sort/Z-Index behavior
    z_index = 10 # Higher value ensures it renders in front of the player

    # 3. Create the main parallel tween for position and fading
    var tween = create_tween()
    tween.set_parallel(true)

    var duration: float = 0.6 # Total duration of the animation
    var peak_height: float = 60.0 # Peak height of the parabolic arc
    var flip_count: int = 4 # Number of 3D flips during flight

    var start_pos = global_position

    # 4. Parabolic motion: X-axis tracking the player smoothly
    tween.tween_method(
        func(t: float):
            global_position.x = lerp(start_pos.x, player.global_position.x, t),
        0.0, 1.0, duration
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

    # 5. Parabolic motion: Y-axis arc calculation
    tween.tween_method(
        func(t: float):
            var linear_y = lerp(start_pos.y, player.global_position.y, t)
            var arc = 4.0 * t * (1.0 - t) * peak_height
            global_position.y = linear_y - arc,
        0.0, 1.0, duration
    ).set_trans(Tween.TRANS_LINEAR)

    # 6. 3D Coin Spin Effect via horizontal scale flipping
    var spin_tween = create_tween()
    spin_tween.set_loops(flip_count)
    var single_flip_time = duration / (flip_count * 2.0)

    # Flip from front to back (scale.x from 1 to -1)
    spin_tween.tween_property(sprite, "scale:x", -1.0, single_flip_time).set_trans(Tween.TRANS_SINE)
    # Flip from back to front (scale.x from -1 to 1)
    spin_tween.tween_property(sprite, "scale:x", 1.0, single_flip_time).set_trans(Tween.TRANS_SINE)

    # 7. Fade out and shrink vertically only at the very end of the animation
    var fade_delay: float = duration * 0.7 # Starts fading at 70% of the flight
    var fade_duration: float = duration - fade_delay

    tween.tween_property(sprite, "scale:y", 0.0, fade_duration).set_delay(fade_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(sprite, "modulate:a", 0.0, fade_duration).set_delay(fade_delay)


    # 8. Clean up nodes when the animation finishes
    tween.chain().tween_callback(func():
        spin_tween.kill() # Ensure the looping sub-tween is freed
        queue_free()
    )


func _get_configuration_warnings() -> PackedStringArray:
    if Utils.is_editing_own_scene(self):
        return []

    var warnings: PackedStringArray = []
    if !item_data and owner:
        warnings.append("Item data is not set")
    return warnings
