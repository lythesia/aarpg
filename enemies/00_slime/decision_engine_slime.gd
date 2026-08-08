class_name DecisionEngineSlime
extends DecisionEngine

# Included in DecisionEngine
# var enemy: Enemy
# var previous_state: EnemyState
# var current_state: EnemyState
# var blackboard: Blackboard

@onready var es_idle: EsIdle = %EsIdle
@onready var es_wander: EsWander = %EsWander
@onready var es_stun: EsStun = %EsStun
@onready var es_death: EsDeath = %EsDeath
@onready var es_chase: EsChase = %EsChase

func _ready() -> void:
    await super() # basic setup

func decide() -> EnemyState:
    # handle damage
    if blackboard.damage_source:
        if blackboard.hp <= 0:
            return es_death
        else:
            return es_stun

    # cannot decide next state (stay)
    if current_state is EsDeath or !blackboard.can_decide:
        return EnemyState.STAY

    # no damage source
    # can decide next state

    # has target
    if blackboard.target:
        if (current_state is not EsChase) and es_chase.can_chase():
            return es_chase
        else:
            if !es_chase.can_chase():
                return es_wander
            else:
                return EnemyState.STAY
    # no target
    else:
        if current_state is EsIdle:
            if current_state.ended:
                return es_wander
            else:
                return EnemyState.STAY
        elif current_state is EsWander:
            if current_state.ended:
                return es_idle
            else:
                return EnemyState.STAY

    # bug here, cannot simply return previous_state, it maybe inconsistent with current blackboard
    # e.g. prev is es_stun, but es_stun is only valid when `damage_source` is not null
    # return previous_state
    return es_idle
