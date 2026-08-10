class_name Pot extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_area: DamageArea = $DamageArea

func _ready() -> void:
    damage_area.DamageTaken.connect(_on_damage_taken.unbind(1))

func _on_damage_taken() -> void:
    if animation_player.has_animation("destroy"):
        animation_player.play("destroy")
        await animation_player.animation_finished
    queue_free()
