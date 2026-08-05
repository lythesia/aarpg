@tool
extends NpcBehavior

const COLORS: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PINK, Color.ORANGE, Color.BROWN, Color.GRAY, Color.CYAN, Color.MAGENTA]

@export var walk_speed: float = 30.0

var patrol_locations: Array[PatrolLocation] = []
var current_idx: int = 0
var target: PatrolLocation

func _ready() -> void:
    _gather_patrol_locations()
    if Engine.is_editor_hint():
        child_entered_tree.connect(func(_node): _gather_patrol_locations())
        child_order_changed.connect(_gather_patrol_locations)
        return

    if patrol_locations.is_empty():
        process_mode = Node.PROCESS_MODE_DISABLED
        return

    target = patrol_locations[current_idx]

    super()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    # target reached with eps tolerance, just do idle -> walk again
    if npc.global_position.distance_to(target.target_pos) <= 1.0:
        start()

func _gather_patrol_locations() -> void:
    patrol_locations = []
    for c in get_children():
        if c is PatrolLocation:
            patrol_locations.append(c)

    if Engine.is_editor_hint():
        if !patrol_locations.is_empty():
            var nloc: int = patrol_locations.size()
            for i in nloc:
                var loc: PatrolLocation = patrol_locations[i]
                if !loc.TransformChanged.is_connected(_gather_patrol_locations):
                    loc.TransformChanged.connect(_gather_patrol_locations)
                loc._update_seq_label(i + 1)
                loc._update_line(patrol_locations[(i + 1) % nloc].position)
                loc.modulate = COLORS[i % COLORS.size()]


func start() -> void:
    if !npc.can_behave or patrol_locations.size() < 2:
        return

    # idle phase
    # 1st patrol point should always be = npc.global_position
    npc.global_position = target.target_pos
    npc.state = "idle"
    npc.velocity = Vector2.ZERO
    npc.update_animation()
    var wait_time: float = target.wait_time
    # update target before timer
    current_idx = (current_idx + 1) % patrol_locations.size()
    target = patrol_locations[current_idx]
    await get_tree().create_timer(wait_time).timeout

    # walk phase
    if !npc.can_behave:
        return
    npc.state = "walk"
    # print("walk: %v -> %v" % [npc.global_position, target.target_pos])
    npc.dir = npc.global_position.direction_to(target.target_pos)
    npc.velocity = npc.dir * walk_speed
    npc.update_direction(target.target_pos)
    npc.update_animation()
