@icon("res://public/icons/player_spawn.svg")
class_name PlayerSpawn extends Node2D

const PLAYER_SCENE: PackedScene = preload("uid://dgj4nm6qm1ggp")

func _ready() -> void:
    visible = false
    await get_tree().process_frame

    # check if already exists a player
    if get_tree().get_first_node_in_group("Player"):
        # print("Player already exists, skipping spawn")
        return

    # instantiate player
    # print("Spawning player")
    var player: Player = PLAYER_SCENE.instantiate()
    get_tree().current_scene.add_child(player) # player will reparent self in its `_ready()`

    # position player
    player.position = self.global_position
