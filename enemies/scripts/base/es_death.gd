class_name EsDeath
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

func enter() -> void:
    # level up at once when enemy dies
    PlayerManager.gain_xp(enemy.xp)

    enemy.update_animation(anim_name)

    blackboard.damage_source = null
    blackboard.can_decide = false
    # while await enemy.animation_player.animation_finished != enemy.get_animation(anim_name):
    #     pass
    await enemy.animation_player.animation_finished

    enemy.queue_free()

func physics_update(_delta: float) -> void:
    enemy.velocity = Vector2.ZERO
