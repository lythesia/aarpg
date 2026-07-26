class_name DecisionEngine extends Node

var enemy: Enemy
var previous_state: EnemyState
var current_state: EnemyState
var blackboard: Blackboard

func _ready() -> void:
    while !enemy:
        await get_tree().process_frame
    # enemy.change_direction(1.0 if enemy.face_east_on_start else -1.0)

func decide() -> EnemyState:
    return EnemyState.STAY
