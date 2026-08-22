class_name EsTeleport
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

@onready var fireball_spawner: ProjectileSpawner = %FireballSpawner
@onready var label: Label = %Label

var animation_player: AnimationPlayer

var curr_idx: int = 0
var positions: Array[Vector2] = []

enum Dir {DOWN, UP, RIGHT, LEFT}
var position_anim_dirs: Array[Dir] = [] # face direction
var curr_dir: Dir = Dir.DOWN

var ended: bool = false

func setup(f: EnemyStateMachine, e: Enemy, b: Blackboard) -> void:
    super(f, e, b)
    var teleport_positions: Node2D = enemy.get_node("../TeleportPositions")
    assert(teleport_positions, "TeleportPositions not found")
    for c in teleport_positions.get_children():
        positions.append(c.global_position)
        # print("position: %s" % c.global_position)
        if c.name.containsn("top"):
            position_anim_dirs.append(Dir.DOWN)
        elif c.name.containsn("bottom"):
            position_anim_dirs.append(Dir.UP)
        elif c.name.containsn("left"):
            # on left, facing right
            position_anim_dirs.append(Dir.RIGHT)
        else:
            # on right, facing left
            position_anim_dirs.append(Dir.LEFT)

    animation_player = enemy.get_node("Sprite2D/AnimationPlayer")
    assert(animation_player, "Cloak AnimationPlayer not found")

    teleport_positions.hide()

func enter() -> void:
    ended = false
    await _teleport()
    ended = true

func exit() -> void:
    ended = true

func physics_update(_delta: float) -> void:
    # label.text = "%s: scale=%v" % [fsm.current_state.name, enemy.scale]
    pass

func _teleport() -> void:
    enemy.animation_player.play("disappear")
    # disable collision
    enemy.hazard_area.set_active(false)
    enemy.damage_area.start_invulnerable()
    enemy.collision_shape.disabled = true

    # fire ball
    fireball_spawner.fire_at_player(0.5) # fire at end of disappear animation

    await get_tree().create_timer(1).timeout

    enemy.global_position = positions[curr_idx]
    curr_dir = position_anim_dirs[curr_idx]
    # update animation direction
    _update_animation()

    enemy.animation_player.play("appear")
    await enemy.animation_player.animation_finished
    # enable collision
    enemy.hazard_area.set_active(true)
    enemy.damage_area.end_invulnerable()
    enemy.collision_shape.disabled = false

    # next teleport position
    _next_index()

func _update_animation() -> void:
    var dir: Dir = position_anim_dirs[curr_idx]
    var anim: String = _get_cloak_animation(dir)
    animation_player.play(anim)
    if dir == Dir.LEFT:
        # scale.x unexpectedly mass up scale.y, check:
        # https://docs.godotengine.org/en/4.0/classes/class_node2d.html#class-node2d-property-scale
        # https://forum.godotengine.org/t/why-my-character-scale-keep-changing/13909/5
        enemy.transform.x.x = -1
    else:
        enemy.transform.x.x = 1

func _set_sprites_flip(flip: bool) -> void:
    enemy.sprite.flip_h = flip

func _get_cloak_animation(dir: Dir) -> String:
    match dir:
        Dir.DOWN: return "down"
        Dir.UP: return "up"
        _: return "side"

func _next_index() -> void:
    var vs = range(positions.size())
    vs.remove_at(curr_idx)
    curr_idx = vs.pick_random()
    # curr_idx = (curr_idx + 1) % positions.size()
