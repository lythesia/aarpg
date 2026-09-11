@tool
class_name ZonePreview extends Node2D

const GRID_SIZE: float = 32
## radius in grid units
@export var radius: int = 1:
    set(v):
        radius = v
        queue_redraw()

@export var color: Color = Color.RED

# func _ready() -> void:
#     if !Engine.is_editor_hint():
#         var pos: Vector2 = global_position
#         reparent.call_deferred(get_tree().root)
#         await get_tree().process_frame
#         global_transform = Transform2D.IDENTITY
#         global_position = pos
#         queue_redraw()

func _draw() -> void:
    if Engine.is_editor_hint() and radius > 0:
        draw_circle(Vector2.ZERO, radius * GRID_SIZE, color, false, 1.0)
