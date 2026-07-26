# class_name DecisionEngine ENGINE
extends DecisionEngine
# meta-name: DecisionEngine
# meta-description: Boilerplate decision engine script
# meta-default: true

# Included in DecisionEngine
# var enemy: Enemy
# var previous_state: EnemyState
# var current_state: EnemyState
# var blackboard: Blackboard

func _ready() -> void:
    await super() # basic setup

func decide() -> EnemyState:
    # common flows
    # if blackboard.damage_source:
    #     if blackboard.hp <= 0:
    #         return es_death
    #     return es_stun
    # if current_state is ESDeath or !blackboard.can_decide:
    #     return null
    # if blackboard.target:
    #     if blackboard.distance_to_target < 40:
    #         return es_attack
    #     return chase
    return previous_state
