class_name CameraHelper extends Node

@onready var pcam: PhantomCamera2D = %PhantomCamera2D

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    # wait player
    var player: Player = PlayerManager.get_player()
    while player == null:
        player = PlayerManager.get_player()
        await get_tree().process_frame

    if !pcam:
        pcam = %PhantomCamera2D
    pcam.set_tween_duration(0.0)
    pcam.set_follow_target(player)
    pcam.teleport_position()
