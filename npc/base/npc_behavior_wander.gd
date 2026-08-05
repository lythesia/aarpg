@tool
extends NpcBehavior

const DIRECTIONS = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

## range in grids
@export var wander_range: int = 2: set = _set_wander_range
const GRID_SIZE: int = 32
@export var wander_speed: float = 30.0
@export var wander_dur: float = 1.0
@export var idle_dur: float = 1.0

## circle assumed
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var orig_pos: Vector2

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    super()
    collision_shape.queue_free()
    orig_pos = npc.global_position

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    if abs(global_position.distance_to(orig_pos)) > wander_range * GRID_SIZE:
        npc.velocity *= -1
        npc.dir *= -1
        npc.update_direction(global_position + npc.dir)
        npc.update_animation()

func start() -> void:
    if !npc.can_behave:
        return

    # idle phase
    npc.state = "idle"
    npc.velocity = Vector2.ZERO
    npc.update_animation()
    await get_tree().create_timer(randf() * idle_dur + idle_dur).timeout

    # walk phase
    npc.state = "walk"
    var _dir: Vector2 = DIRECTIONS[randi_range(0, 3)]
    npc.velocity = _dir * wander_speed
    npc.update_direction(global_position + _dir)
    npc.update_animation()
    await get_tree().create_timer(randf() * wander_dur + wander_dur).timeout

    # repeat
    if !npc.can_behave:
        return
    start() # tail recursion?

func _set_wander_range(value: int) -> void:
    wander_range = value
    collision_shape.shape.radius = value * GRID_SIZE
