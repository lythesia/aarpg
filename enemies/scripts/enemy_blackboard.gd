class_name Blackboard extends Resource

var hp: float = 0.0
var target: Player = null
var distance_to_target: float = -1
var can_decide: bool = true
var damage_source: AttackArea = null
var dir: Vector2 = Vector2.ZERO
var cardinal_dir: Vector2 = Vector2.DOWN

func update_distance_to_target(self_pos: Vector2) -> void:
    if target:
        distance_to_target = self_pos.distance_to(target.global_position)
    else:
        distance_to_target = -1
