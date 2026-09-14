@tool
class_name DarkWizard extends Enemy

@export var cloak_animation_player: AnimationPlayer:
    set(v):
        cloak_animation_player = v
        if Engine.is_editor_hint():
            update_configuration_warnings()

func _ready() -> void:
    super()
    WasHit.connect(_was_hit)
    WasKilled.connect(_was_killed)

func update_cloak_animation(dir: Vector2) -> void:
    cloak_animation_player.play(_get_cloak_animation(dir))
    if dir == Vector2.LEFT:
        # scale.x unexpectedly mass up scale.y, check:
        # https://docs.godotengine.org/en/4.0/classes/class_node2d.html#class-node2d-property-scale
        # https://forum.godotengine.org/t/why-my-character-scale-keep-changing/13909/5
        transform.x.x = -1
    else:
        transform.x.x = 1

func _get_cloak_animation(dir: Vector2) -> String:
    match dir:
        Vector2.DOWN: return "down"
        Vector2.UP: return "up"
        _: return "side"

func _was_hit(attack_area: AttackArea) -> void:
    if attack_area.damage_amount > 0:
        animation_player.play("stun")
        animation_player.seek(0) # restart animation anyway
        damage_area.make_invulnerable(1)

func _was_killed() -> void:
    btplayer.active = false
    PlayerManager.gain_xp(xp)
    animation_player.play("death")
    await animation_player.animation_finished
    queue_free()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = super()
    if !cloak_animation_player:
        warnings.append("Cloak animation player not set")
    return warnings
