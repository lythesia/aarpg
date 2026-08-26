class_name Torch extends Node2D

@export var fireball_spawner: ProjectileSpawner
@export var initial_delay: float = 1.0
@export var fire_interval: float = 2.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var started: bool = false
var player: Player

func _ready() -> void:
    # make torch flame random
    var anim_len: float = animation_player.current_animation_length
    var offset = anim_len * randf()
    animation_player.seek(offset)

    # try get spawner nodes if in child but not assigned yet
    if !fireball_spawner:
        for c in find_children("*", "ProjectileSpawner"):
            # skip if disabled
            if c.process_mode == Node.PROCESS_MODE_DISABLED:
                break
            # found & attach
            else:
                fireball_spawner = c
                break

    started = false
    player = null

func _process(_delta: float) -> void:
    if started:
        return

    if not fireball_spawner:
        return

    var _player = PlayerManager.get_player()
    if not (_player and PlayerManager.player_in_scene(get_tree().current_scene)):
        return
    player = _player

    started = true
    get_tree().create_timer(initial_delay).timeout.connect(start_firing)

func start_firing() -> void:
    if player and !player.is_dead():
        fireball_spawner.fire(player.global_position)
        await get_tree().create_timer(fire_interval).timeout
        start_firing.call_deferred()
