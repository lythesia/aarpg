@tool
class_name Level extends Node2D

func _ready() -> void:
    # enable y-sort
    y_sort_enabled = true

    if Engine.is_editor_hint():
        return
