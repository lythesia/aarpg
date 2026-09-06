class_name ThrowableBomb extends Throwable

@export_category("Bomb Settings")
@export_range(1, 10, 0.1, "s") var fuse_dur: float = 4.0

@export_category("Bounce Settings")
@export_range(0.1, 0.9, 0.05) var bounce_damp: float = 0.25
@export_range(1, 10, 1) var max_bounces: int = 5

@onready var explosion_sprite: Sprite2D = $"../ExplosionSprite"

var bounces: int = 0
var orig_throw_speed: float = 0

func _ready() -> void:
    super()
    orig_throw_speed = throw_speed
    attack_area.damage_amount = 0 # deal no damage but still trigger `DamageDealt`
    animation_player.queue("explode")
    animation_player.animation_changed.connect(_on_explode.unbind(2))
    animation_player.speed_scale = animation_player.current_animation_length / fuse_dur

func _on_explode() -> void:
    animation_player.speed_scale = 1

# override
func hit_ground() -> void:
    bounces += 1

    if bounces <= max_bounces:
        object_sprite.position.y = ground_height - 1
        verticle_velocity *= -1.0 * bounce_damp
        throw_speed *= bounce_damp
    else:
        set_physics_process(false)
        attack_area.set_active.call_deferred(false)
        if attack_area.DamageDealt.is_connected(attack_damage_dealt):
            attack_area.DamageDealt.disconnect(attack_damage_dealt)
        if wall_detect.body_entered.is_connected(_on_wall_detected):
            wall_detect.body_entered.disconnect(_on_wall_detected)
        # re-pickable
        area_entered.connect(_on_area_entered)
        area_exited.connect(_on_area_exited)
        _enable_collision(throwable_object)

func _on_player_interacted() -> void:
    super()
    throw_speed = orig_throw_speed
    bounces = 0

# override
func hit_wall() -> void:
    on_hit()

# override
func attack_damage_dealt() -> void:
    on_hit()

func on_hit() -> void:
    var throw_magnitude: Vector2 = throw_dir.abs()
    # horizontal throw
    if throw_magnitude.x > throw_magnitude.y:
        throw_dir.x *= -1
    # vertical throw
    else:
        throw_dir.y *= -1
    throw_speed *= bounce_damp

# override
func _disable_collision(node: Node) -> void:
    super(node)
    # we never disable explosion hazard area
    $"../HazardArea/CollisionShape2D".disabled = false
