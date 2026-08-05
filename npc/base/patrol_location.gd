@tool
class_name PatrolLocation extends Node2D

signal TransformChanged

@export var wait_time: float = 1.0:
    set(v):
        wait_time = v
        _update_wait_time_label()

var target_pos: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
    set_notify_transform(true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_TRANSFORM_CHANGED:
        TransformChanged.emit()

func _ready() -> void:
    target_pos = global_position

    if Engine.is_editor_hint():
        return

    print("%s: %v" % [name, target_pos])
    $Sprite2D.queue_free()

func _update_seq_label(seq: int) -> void:
    if Engine.is_editor_hint():
        $Sprite2D/SeqLabel.text = str(seq)

func _update_wait_time_label() -> void:
    if Engine.is_editor_hint():
        $Sprite2D/WaitTimeLabel.text = "Wait: %.1fs" % wait_time

## remember we use `position` instead of `global_position` to calc diff here
func _update_line(next: Vector2) -> void:
    var line: Line2D = $Sprite2D/Line2D
    line.set_point_position(1, next - position)
