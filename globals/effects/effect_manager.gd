extends Node

const DAMAGE_TEXT: PackedScene = preload("uid://bcbbsefh4o8xm")

func damage_text(damage_amount: int, start_pos: Vector2) -> void:
    var d: DamageText = DAMAGE_TEXT.instantiate()
    add_child(d)
    d.start(str(damage_amount), start_pos)
