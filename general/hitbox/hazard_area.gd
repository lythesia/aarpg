@icon("res://public/icons/hazard_area.svg")
class_name HazardArea extends AttackArea

func _ready() -> void:
    super()
    self.visible = true
    self.monitoring = true
