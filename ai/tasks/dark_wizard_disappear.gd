extends BTAction

var enemy: Enemy

func _enter() -> void:
    enemy = agent as Enemy
    enemy.animation_player.play("disappear")
    # disable collision
    enemy.hazard_area.set_active(false)
    enemy.damage_area.start_invulnerable()
    enemy.collision_shape.disabled = true

func _tick(_delta: float) -> Status:
    if enemy.animation_player.current_animation == "disappear" and \
        enemy.animation_player.is_playing():
        return Status.RUNNING
    else:
        return Status.SUCCESS
