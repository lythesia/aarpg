class_name DecisionEngineDarkWizard
extends DecisionEngine

# Included in DecisionEngine
# var enemy: Enemy
# var previous_state: EnemyState
# var current_state: EnemyState
# var blackboard: Blackboard

@onready var es_idle: EsIdle = %EsIdle
@onready var es_death: EsDeath = %EsDeath
@onready var es_teleport: EsTeleport = %EsTeleport
@onready var es_attack: EsDarkWizardAttack = %EsDarkWizardAttack

func _ready() -> void:
    await super() # basic setup
    enemy.WasHit.connect(_on_hit)

func decide() -> EnemyState:
    if blackboard.hp <= 0:
        return es_death

    if current_state is EsDeath or !blackboard.can_decide:
        return EnemyState.STAY

    if current_state is EsIdle:
        if current_state.ended:
            return es_teleport
        else:
            return EnemyState.STAY
    elif current_state is EsTeleport:
        if current_state.ended:
            return es_attack
        else:
            return EnemyState.STAY
    elif current_state is EsDarkWizardAttack:
        if current_state.ended:
            return es_idle
        else:
            return EnemyState.STAY

    return es_idle

func _on_hit(attack_area: AttackArea) -> void:
    if attack_area.damage_amount > 0:
        enemy.animation_player.play("stun")
        enemy.animation_player.seek(0) # restart animation anyway
        enemy.damage_area.make_invulnerable(0.8) # actually "stun" animation is 1.0s
