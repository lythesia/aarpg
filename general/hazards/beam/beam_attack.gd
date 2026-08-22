class_name BeamAttack extends Node2D

@export var activate_timer: Timer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard_area: HazardArea = $HazardArea

func _ready() -> void:
    # disable hazard area at first
    hazard_area.monitoring = false

    # try get timer node
    if !activate_timer:
        for c in find_children("*", "Timer"):
            activate_timer = c
            break

    if activate_timer:
        activate_timer.timeout.connect(activate)
        activate_timer.start()

func activate() -> void:
    animation_player.play("activate")
    animation_player.queue("default")
