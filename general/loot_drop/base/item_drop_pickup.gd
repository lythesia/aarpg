@tool
class_name ItemDropPickup extends ItemPickup

## Override ItemPickup's pickup animation with custom animation in ItemDropPickup
@export var override_pickup_animation: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const initial_speed: float = 60.0
const decelerate: float = 5.0

var initial_delay_percent: float = 0.0

func _ready() -> void:
    super()

    if Engine.is_editor_hint():
        return

    initial_delay_percent = randf()
    while initial_delay_percent >= 1.0:
        initial_delay_percent = randf()

    _set_start_frame_if_has_default_animation()

    # bounce(from global library) first if we have
    if animation_player.has_animation("bounce"):
        animation_player.play("bounce")
        animation_player.animation_finished.connect(_on_animation_finished)

    var direction = Vector2.RIGHT.rotated(randf_range(0.0, 2.0 * PI))

    # initialize velocity
    velocity = direction * initial_speed

func _physics_process(delta: float) -> void:
    velocity -= decelerate * delta * velocity
    move_and_slide()

func play_pickup_animation(player: Node2D) -> void:
    if override_pickup_animation:
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
    # use ItemPickup's animation
    else:
        super(player)

func _set_start_frame_if_has_default_animation() -> void:
    if !animation_player.has_animation("sub/default"):
        return

    var start_frame: int = int(initial_delay_percent * sprite.hframes * sprite.vframes)
    sprite.frame = start_frame

# try to play "sub/default" animation with initial delay
func _on_animation_finished(anim_name: String) -> void:
    if anim_name != "bounce" or !animation_player.has_animation("sub/default"):
        return

    var anim: String = "sub/default"
    var start_time: float = initial_delay_percent * animation_player.get_animation(anim).length
    animation_player.play(anim)
    animation_player.seek(start_time, true)
