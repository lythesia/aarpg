@tool
class_name PartrolPreview extends Node2D

const COLORS: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PINK, Color.ORANGE, Color.BROWN, Color.GRAY, Color.CYAN, Color.MAGENTA]

var patrol_locations: Array[PatrolLocation] = []

func _ready() -> void:
    _gather_patrol_locations()
    if Engine.is_editor_hint():
        child_entered_tree.connect(_gather_patrol_locations.unbind(1))
        child_order_changed.connect(_gather_patrol_locations)
        return

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
