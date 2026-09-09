extends Node2D

@onready var pcam: PhantomCamera2D = %SecondaryPcam
@onready var peak_area: Area2D = %PeakArea

func _ready() -> void:
    PlayerManager.PlayerRepositioned.connect(_on_player_repositioned, CONNECT_ONE_SHOT)

func _on_player_repositioned() -> void:
    peak_area.body_entered.connect(_enter_peak_area)
    peak_area.body_exited.connect(_exit_peak_area)

func _enter_peak_area(body: Node2D) -> void:
    if body is Player:
        pcam.set_priority(2)

func _exit_peak_area(body: Node2D) -> void:
    if body is Player:
        pcam.set_priority(0)
