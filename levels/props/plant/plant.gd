class_name Plant extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_area: DamageArea = $DamageArea

func _ready() -> void:
    damage_area.DamageTaken.connect(_on_damage_taken)

func _on_damage_taken(_attack_area: AttackArea) -> void:
    animation_player.play("destroy")
    await animation_player.animation_finished
    queue_free()
