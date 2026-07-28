@icon("res://public/icons/attack_area.svg")
class_name AttackArea extends Area2D

signal DamageDealt

@export var damage_amount: int = 0

func _ready() -> void:
    self.visible = false
    self.monitoring = false # we can initially set it false until `set_active`
    self.monitorable = false

    # detects body
    # self.body_entered.connect(_on_body_entered)
    # detects area, so DamageArea gonna trigger this
    self.area_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body is DamageArea:
        DamageDealt.emit()
        body.take_damage(self)

func set_active(active: bool = true) -> void:
    self.visible = active
    self.monitoring = active
