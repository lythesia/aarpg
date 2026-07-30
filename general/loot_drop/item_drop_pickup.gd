@tool
class_name ItemDropPickup extends ItemPickup

## pickup_size control sprite & collision area
# @export var pickup_size: float = 10.0

@export_category("Drop throw range")
## sample one point within range when drop
@export_range(0.0, 100.0) var throw_range: float = 5.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    super()

    if Engine.is_editor_hint():
        return

    if animation_player.has_animation("default"):
        animation_player.play("default")

    var direction = Vector2.RIGHT.rotated(randf_range(0.0, 2.0 * PI))
    var target_offset = direction * throw_range
    throw_item.call_deferred(target_offset)

#region throw animation

## Main function to handle horizontal travel and trigger vertical bounce
func throw_item(target_offset: Vector2, duration: float = 0.8) -> void:
    # Handle initial visibility of the shadow based on the control flag
    if not has_shadow:
        shadow_sprite.visible = false

    # Create a parallel tween so ground movement and bouncing happen simultaneously
    var main_tween = create_tween().set_parallel(true)

    # 1. Ground Movement: Move the entire Area2D to the target ground destination
    main_tween.tween_property(self, "position", position + target_offset, duration) \
        .set_trans(Tween.TRANS_QUAD) \
        .set_ease(Tween.EASE_OUT)

    # 2. Vertical Bounce: Animate the Sprite height and Shadow scale over time
    # _animate_bounce(duration)


## Sequence function to handle the consecutive bounces
func _animate_bounce(total_duration: float) -> void:
    # Create a sequential tween to chain the bounces step-by-step
    var bounce_tween = create_tween()

    # Bounce configurations: [Peak Height (pixels), Time Duration Ratio]
    # Negative Y moves UP in Godot 2D coordinates
    var bounce_data = [
        [-60.0, total_duration * 0.4], # First bounce (Highest)
        [-25.0, total_duration * 0.3], # Second bounce
        [-10.0, total_duration * 0.2], # Third bounce (Micro-bounce)
        [0.0, total_duration * 0.1] # Settle on the ground
    ]

    for i in range(bounce_data.size()):
        var target_height = bounce_data[i][0]
        var bounce_time = bounce_data[i][1]

        # Half of the duration is spent going up, the other half coming down
        var half_time = bounce_time * 0.5

        if target_height != 0.0:
            # --- PHASE 1: GOING UP ---
            var up_phase = bounce_tween.parallel()
            # Move sprite up (TRANS_QUAD + EASE_OUT simulates gravity deceleration)
            up_phase.tween_property(sprite, "position:y", target_height, half_time) \
                .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

            # Only animate shadow scale if the item has a shadow enabled
            if has_shadow:
                up_phase.tween_property(shadow_sprite, "scale", Vector2(0.6, 0.6), half_time) \
                    .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

            # --- PHASE 2: GOING DOWN ---
            var down_phase = bounce_tween.chain().parallel()
            # Move sprite back to ground level 0 (TRANS_QUAD + EASE_IN simulates gravity acceleration)
            down_phase.tween_property(sprite, "position:y", 0.0, half_time) \
                .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

            # Only animate shadow scale if the item has a shadow enabled
            if has_shadow:
                down_phase.tween_property(shadow_sprite, "scale", Vector2(1.0, 1.0), half_time) \
                    .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

            # --- OPTIONAL: SQUASH & STRETCH JUICE ---
            # Add a tiny visual impact effect exactly when it hits the ground
            _add_impact_juice(bounce_tween)

        else:
            # Final settlement phase to ensure everything is perfectly reset
            var final_phase = bounce_tween.chain().parallel()
            final_phase.tween_property(sprite, "position:y", 0.0, bounce_time)

            if has_shadow:
                final_phase.tween_property(shadow_sprite, "scale", Vector2(1.0, 1.0), bounce_time)

    # Re-enable Area2D detection after the bounce animation completely finishes
    # bounce_tween.tween_callback(func():
    #     area.monitoring = true
    # )

## Helper function to apply squash/stretch squeeze effects upon hitting the floor
func _add_impact_juice(tween: Tween) -> void:
    # Squash flat on impact
    tween.chain().tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.04)
    # Recover back to normal pickup_size
    tween.chain().tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.04)

#endregion

func play_pickup_animation(player: Node2D) -> void:
    if has_animation:
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

        var start_pos = global_position
        _tween_trajectory(tween, duration, peak_height, start_pos, player)

        tween.chain().tween_callback(func():
            queue_free()
        )
    else:
        super(player)
