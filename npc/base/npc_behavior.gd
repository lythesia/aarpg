@icon("res://npc/assets/icons/npc_behavior.svg")
@abstract
class_name NpcBehavior extends Node2D

var npc: NPC

func _ready() -> void:
    var parent: Node = get_parent()
    if parent and parent is NPC:
        npc = parent
        npc.DoBehave.connect(start)

@abstract
func start() -> void
