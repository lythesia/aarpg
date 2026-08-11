class_name Projectile extends CharacterBody2D

@export var move_speed: float = 150.0
@export var lifetime: float = 5.0

@export_category("Audio")
@export var spawn_audio: AudioStream
@export var destroy_audio: AudioStream


var animation_player: AnimationPlayer
var attack_area: AttackArea
var sprite: Sprite2D

func _ready() -> void:
    for c in get_children():
        if c is AttackArea:
            attack_area = c
            attack_area.set_active(true)
            attack_area.DamageDealt.connect(_on_damage_dealt)
        elif c is AnimationPlayer:
            animation_player = c
        elif c is Sprite2D:
            sprite = c

    _lifetime_timer()
    hide() # show until fire

# todo: need to make new collision layer for projectiles, coz if fire device
# is same as wall, projectiles will likely collide with the device on spawn
# because they are very close
# goal: 1. projectile collide wall, items, etc.
#       2. not collide with fire device
func _physics_process(delta: float) -> void:
    var colli = move_and_collide(velocity * delta)
    if colli:
        destory(true)

## fire the projectile
func start(target: Vector2) -> void:
    var dir = global_position.direction_to(target)
    rotate(dir.angle())
    velocity = dir * move_speed
    Audio.play_spatial_sound(spawn_audio, position)
    show()

func _on_damage_dealt():
    destory.call_deferred(true)

func _lifetime_timer() -> void:
    await get_tree().create_timer(lifetime).timeout
    destory()

func destory(play_audio: bool = false):
    velocity = Vector2.ZERO

    if play_audio:
        Audio.play_spatial_sound(destroy_audio, position)

    if attack_area:
        attack_area.set_active(false)

    if animation_player and animation_player.has_animation("destroy"):
        animation_player.play("destroy")
        await animation_player.animation_finished

    queue_free()
