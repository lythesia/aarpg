extends BTAction

var enemy: Enemy

func _enter() -> void:
    enemy = agent as Enemy
    enemy.animation_player.play("appear")

func _tick(_delta: float) -> Status:
    if enemy.animation_player.current_animation == "appear" and \
        enemy.animation_player.is_playing():
        return Status.RUNNING
    else:
        # enable collision
        enemy.hazard_area.set_active(true)
        enemy.damage_area.end_invulnerable()
        enemy.collision_shape.disabled = false
        return Status.SUCCESS
