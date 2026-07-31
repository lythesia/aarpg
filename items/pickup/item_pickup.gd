@tool
class_name ItemPickup extends CharacterBody2D

enum TextureType {
    ## use item data's static atlas texture
    ITEM_DATA,
    ## Manually set the texture
    CUSTOM,
}

@export var item_data: ItemData: set = _set_item_data
@export var pickup_audio: AudioStream
@export var has_shadow: bool = true: set = _set_has_shadow
@export var texture_type: TextureType: set = _set_texture_type

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var shadow_sprite: Sprite2D = $ShadowSprite

func _ready() -> void:
    if !has_shadow:
        shadow_sprite.visible = false

    _update_texture()
    _update_shadow()

    if Engine.is_editor_hint():
        return

    area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is Player and item_data:
        if PlayerManager.INVENTORY_DATA.add_item(item_data):
            item_picked_up(body)

func _set_item_data(value: ItemData) -> void:
    item_data = value

    if Engine.is_editor_hint() and is_node_ready():
        _update_texture()
        update_configuration_warnings()

func _update_texture() -> void:
    match texture_type:
        TextureType.ITEM_DATA:
            if item_data and sprite:
                sprite.texture = item_data.icon
            elif sprite:
                sprite.texture = null
        TextureType.CUSTOM:
            pass

func _set_has_shadow(value: bool) -> void:
    has_shadow = value
    if Engine.is_editor_hint() and is_node_ready():
        _update_shadow()

func _update_shadow() -> void:
    if shadow_sprite:
        shadow_sprite.visible = has_shadow

func _set_texture_type(value: TextureType) -> void:
    texture_type = value
    if Engine.is_editor_hint() and is_node_ready():
        _update_texture()

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

    _tween_trajectory(tween, duration, peak_height, start_pos, player)

    var spin_tween: Tween = _tween_spin(flip_count, duration)

    var fade_delay: float = duration * 0.7 # Starts fading at 70% of the flight
    _tween_fade(tween, duration, fade_delay)

    # 8. Clean up nodes when the animation finishes
    tween.chain().tween_callback(func():
        spin_tween.kill() # Ensure the looping sub-tween is freed
        queue_free()
    )

func _tween_trajectory(
    tween: Tween,
    duration: float,
    peak_height: float,
    start_pos: Vector2,
    player: Player,
) -> void:
    # 4. Parabolic motion: X-axis tracking the player smoothly
    tween.tween_method(
        func(t: float):
            global_position.x = lerp(start_pos.x, player.global_position.x, t),
        0.0, 1.0, duration
    ).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

    # 5. Parabolic motion: Y-axis arc calculation & Shadow scaling
    tween.tween_method(
        func(t: float):
            var linear_y = lerp(start_pos.y, player.global_position.y, t)
            # arc represents the height above the ground (0.0 at start/end, max at peak)
            var arc = 4.0 * t * (1.0 - t) * peak_height
            global_position.y = linear_y - arc

            # Shadow effect: scale down and fade out as the item flies higher
            if has_shadow:
                var height_ratio = arc / peak_height # 0.0 on ground, 1.0 at peak
                # Shadow shrinks to 40% and fades to 30% opacity at the highest point
                shadow_sprite.scale = Vector2.ONE * (1.0 - height_ratio * 0.6)
                shadow_sprite.modulate.a = 1.0 - height_ratio * 0.7
                # Keep has_shadow at the base height (offset the item's jump up)
                shadow_sprite.position.y = arc,
        0.0,
        1.0,
        duration
    ).set_trans(Tween.TRANS_LINEAR)

func _tween_spin(
    flip_count: int,
    duration: float,
) -> Tween:
    # 6. 3D Coin Spin Effect via horizontal scale flipping
    var spin_tween = create_tween()
    spin_tween.set_loops(flip_count)
    var single_flip_time = duration / (flip_count * 2.0)

    # Flip from front to back (scale.x from 1 to -1)
    spin_tween.tween_property(sprite, "scale:x", -1.0, single_flip_time).set_trans(Tween.TRANS_SINE)
    # Flip from back to front (scale.x from -1 to 1)
    spin_tween.tween_property(sprite, "scale:x", 1.0, single_flip_time).set_trans(Tween.TRANS_SINE)

    return spin_tween

func _tween_fade(
    tween: Tween,
    duration: float,
    fade_delay: float,
) -> void:
    # 7. Fade out and shrink vertically only at the very end of the animation
    var fade_duration: float = duration - fade_delay
    tween.tween_property(sprite, "scale:y", 0.0, fade_duration).set_delay(fade_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(sprite, "modulate:a", 0.0, fade_duration).set_delay(fade_delay)

func _get_configuration_warnings() -> PackedStringArray:
    if Utils.is_editing_own_scene(self):
        return []

    var warnings: PackedStringArray = []
    if !item_data:
        warnings.append("Item data is not set")
    return warnings
