extends Node2D

@onready var cam: CameraHelper = %Cam
@onready var pcam: PhantomCamera2D = %SecondaryPcam
@onready var peak_area: Area2D = %PeakArea

func _ready() -> void:
    PlayerManager.PlayerRepositioned.connect(func(_p):
        # Q: I dont' know what the fuck needs so many frames here to make sure the player is repositioned?!
        for _f in 120:
            await get_tree().process_frame
        peak_area.body_entered.connect(_enter_peak_area)
        peak_area.body_exited.connect(_exit_peak_area)
    )

func _enter_peak_area(body: Node2D) -> void:
    if body is Player:
        pcam.set_priority(2)
        # enable main pcam tween
        if cam.pcam.get_tween_duration() == 0:
            cam.pcam.set_tween_duration(1)

func _exit_peak_area(body: Node2D) -> void:
    if body is Player:
        pcam.set_priority(0)
        # once this one-time tween is done, reset it to 0
        if cam.pcam.get_tween_duration() == 1:
            cam.pcam.set_tween_duration(0)
