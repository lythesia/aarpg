class_name CameraHelper extends Node

@onready var pcam: PhantomCamera2D = %PhantomCamera2D

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    PlayerManager.PlayerRepositioned.connect(_on_player_repositioned)

func _on_player_repositioned(player: Player) -> void:
    pcam.set_tween_duration(0.0)
    pcam.set_follow_target(player)
    pcam.teleport_position()
