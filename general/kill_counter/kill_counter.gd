## enemy kill counter trigger
class_name KillCounter extends Node2D

signal Done

var enemies: Array[Enemy]
var counter: int = 0

func _ready() -> void:
    _gather_enemies()
    for e in enemies:
        e.WasKilled.connect(_on_enemy_killed, CONNECT_ONE_SHOT)

func _gather_enemies() -> void:
    for e in find_children("*", "Enemy"):
        if e is Enemy:
            enemies.append(e)

func _on_enemy_killed() -> void:
    counter += 1
    if counter == enemies.size():
        Done.emit() # manually connect to target **in editor**
