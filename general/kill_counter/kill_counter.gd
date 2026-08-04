## enemy kill counter trigger
class_name KillCounter extends Node2D

signal Done

func _ready() -> void:
    child_exiting_tree.connect(_enemy_exited_tree)

func _enemy_exited_tree(enemy: Node2D) -> void:
    if enemy is Enemy:
        if _count_enemies() == 0:
            Done.emit() # manually connect to target **in editor**

func _count_enemies() -> int:
    return find_children("*", "Enemy").size()
