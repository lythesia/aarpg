class_name PathFinder extends Node2D

@onready var timer: Timer = $Timer

# standard directions
var vectors: Array[Vector2] = [
    Vector2.UP,
    Vector2.UP + Vector2.RIGHT,
    Vector2.RIGHT,
    Vector2.RIGHT + Vector2.DOWN,
    Vector2.DOWN,
    Vector2.DOWN + Vector2.LEFT,
    Vector2.LEFT,
    Vector2.LEFT + Vector2.UP,
]

# raycasts
var rays: Array[RayCast2D] = []
# intensity of interests of direction
var interests: Array[float]
# intensity of obstacles
var obstacles: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
# outcomes
var outcomes: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]

var move_dir: Vector2 = Vector2.ZERO
var best_path: Vector2 = Vector2.ZERO

func _ready() -> void:
    # collect raycasts
    for c in get_children():
        if c is RayCast2D:
            rays.append(c)

    # normalize vectors
    for v in vectors:
        v = v.normalized()

    # perform initial pathfinder
    set_path()

    # connect timer timeout
    timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
    # gradually update `move_dir` towards `best_path`
    # other scripts will ref the `move_dir` during movement logic
    # `lerp` prevents hard direction changes & jiterring or direction confused cases
    move_dir = lerp(move_dir, best_path, 10 * delta)

func set_raycast_len(length: float) -> void:
    for r in rays:
        r.target_position.y = - length

# set best path vector
func set_path() -> void:
    # dir to player
    var player_dir: Vector2 = global_position.direction_to(PlayerManager.get_player().global_position)
    # reset `obstacles`
    obstacles.fill(0.0)
    interests.fill(0.0)
    # check each raycast for collisions & updates `obstacles`
    for i in 8:
        if rays[i].is_colliding():
            obstacles[i] += 4
            # might also collide in neighbour directions
            obstacles[(i + 1) % 8] += 1
            obstacles[(i + 7) % 8] += 1
    # if no obstacles: recommend move towards player
    if obstacles.max() == 0:
        best_path = player_dir
        return
    # else: populate `interests`
    interests.clear()
    for v in vectors:
        interests.append(player_dir.dot(v))
    # populate `outcomes` by combining `interests` and `obstacles`
    for i in 8:
        outcomes[i] = interests[i] - obstacles[i]
    # set `best_path`
    best_path = vectors[outcomes.find(outcomes.max())]

func _on_timer_timeout() -> void:
    set_path()
