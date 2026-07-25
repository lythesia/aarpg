@icon("res://public/icons/damage_area.svg")
class_name DamageArea extends Area2D

signal DamageTaken(attack_area: AttackArea)

func _ready() -> void:
    self.monitoring = false
    self.monitorable = true

func take_damage(attack_area: AttackArea) -> void:
    DamageTaken.emit(attack_area)

# invulneralbe based on timer
func make_invulnerable(dur: float) -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
    await get_tree().create_timer(dur).timeout
    process_mode = Node.PROCESS_MODE_INHERIT

# invulnerable based on start/end pair
func start_invulnerable() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED

func end_invulnerable() -> void:
    process_mode = Node.PROCESS_MODE_INHERIT
