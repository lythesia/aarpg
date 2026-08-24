class_name EsChase
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

const PATH_FINDER: PackedScene = preload("uid://bmkg4awvdj7pe")

@export var path_finder_detect_length: float = 5

@export var speed: float = 40.0
## how much enemy can turn direction during chasing
@export var turn_rate: float = 0.25

@export var step_timer: Timer

var path_finder: PathFinder

func enter() -> void:
    path_finder = PATH_FINDER.instantiate() as PathFinder
    enemy.add_child(path_finder)
    # update raycast length after enter_tree, else `rays` not collected yet
    path_finder.set_raycast_len(path_finder_detect_length)

    enemy.update_animation(anim_name)
    if step_timer:
        # make sure one-shot, we (re)start it manually
        step_timer.one_shot = true

func exit() -> void:
    if path_finder:
        path_finder.queue_free()

    if step_timer:
        step_timer.stop()

# todo: optimize this to avoid enemy jittering at player's position
# we can define min step distance (like es_wander.gd, slime moves one hop as min step)
# enemy always walk min step distance towards player, if pass through player, then
# turnback
func physics_update(_delta: float) -> void:
    # non step mode
    if !step_timer:
        _update_chase_direction()
    # step mode
    else:
        if step_timer.is_stopped():
            # update direction then restart timer
            _update_chase_direction()
            step_timer.start()
        else:
            # timer running, stay in current direction
            pass

    # update move physics anyway
    enemy.velocity = blackboard.dir * speed

func _update_chase_direction(_step_mode: bool = true) -> void:
    var dir = lerp(blackboard.dir, path_finder.move_dir, turn_rate)
    blackboard.dir = dir
    if enemy.update_direction(dir):
        enemy.update_animation(anim_name)

func can_chase() -> bool:
    if !enemy or !blackboard.target:
        return false

    return true
