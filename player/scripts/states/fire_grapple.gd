class_name PlayerStateFireGrapple
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var grapple_distance: float = 100
@export var grapple_speed: float = 200
@export_group("Audio SFX")
@export var fire_audio: AudioStream
@export var stick_audio: AudioStream
@export var clang_audio: AudioStream

@onready var grapple_hook: Node2D = %GrappleHook
var nine_patch_rect: NinePatchRect
var chain_audio_player: AudioStreamPlayer2D
@onready var grapple_raycast: RayCast2D = %GrappleRaycast
@onready var hazard_area: HazardArea = %GrappleHookHazardArea

var collision_pos: Vector2
var collision_dist: float
var collision_type: int = 0 # 0 = none, 1 = wall, 2 = grapple point
var nine_patch_size: float = 25.0

var tween: Tween

# where and what angle should grappple hook be when player facing up/down/left/right
const DIR_IDX: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var positions: Array[Vector3] = [
    Vector3(8, -20, 180), # up
    Vector3(8, -10, 0), # down
    Vector3(-10, -15, 90), # left
    Vector3(10, -15, -90), # right
]

func init():
    grapple_hook.hide()
    nine_patch_rect = grapple_hook.get_node("NinePatchRect")
    chain_audio_player = grapple_hook.get_node("AudioStreamPlayer2D")
    grapple_raycast.enabled = false
    grapple_raycast.target_position.y = grapple_distance
    hazard_area.set_active(false)

func enter():
    player.update_animation("idle")
    grapple_hook.show()

    # set position relative to player
    _set_grapple_hook_position()

    # raycast detection
    _raycast_detection()

    # shoot hook
    hazard_area.set_active(true)
    _shoot_hook()

    chain_audio_player.play()

func exit():
    grapple_hook.hide()
    hazard_area.set_active(false)
    chain_audio_player.stop()
    if tween:
        tween.kill()
    nine_patch_rect.size.y = nine_patch_size

func handle_input(_event: InputEvent) -> PlayerState:
    return STAY

func process(_delta: float) -> PlayerState:
    return STAY

func physics_process(_delta: float) -> PlayerState:
    player.velocity = Vector2.ZERO
    return STAY

func _set_grapple_hook_position() -> void:
    var pos_angle: Vector3 = positions[DIR_IDX.find(player.cardinal_dir)]
    grapple_hook.position = Vector2(pos_angle.x, pos_angle.y)
    grapple_hook.rotation_degrees = pos_angle.z
    grapple_hook.show_behind_parent = player.cardinal_dir == Vector2.UP

const LAYER_WALL: int = 1
const LAYER_GRAPPLE_POINT: int = 4

func _raycast_detection() -> void:
    collision_type = 0
    collision_dist = grapple_distance

    # check for grapple point first
    grapple_raycast.set_collision_mask_value(LAYER_WALL, false)
    grapple_raycast.set_collision_mask_value(LAYER_GRAPPLE_POINT, true)
    grapple_raycast.force_raycast_update() # ignores `enabled` flag

    if grapple_raycast.is_colliding():
        collision_type = 2
        collision_pos = grapple_raycast.get_collision_point()
        collision_dist = collision_pos.distance_to(player.global_position)
        return

    # check for wall then
    grapple_raycast.set_collision_mask_value(LAYER_WALL, true)
    grapple_raycast.set_collision_mask_value(LAYER_GRAPPLE_POINT, false)
    grapple_raycast.force_raycast_update() # ignores `enabled` flag

    if grapple_raycast.is_colliding():
        collision_type = 1
        collision_pos = grapple_raycast.get_collision_point()
        collision_dist = collision_pos.distance_to(player.global_position)
        return

func _shoot_hook() -> void:
    Audio.play_spatial_sound(fire_audio, player.global_position)
    if tween:
        tween.kill()

    var dur: float = collision_dist / grapple_speed
    tween = create_tween()
    tween.tween_property(nine_patch_rect, "size", Vector2(nine_patch_rect.size.x, collision_dist), dur)
    if collision_type == 2:
        tween.tween_callback(_grapple_player)
    else:
        tween.tween_callback(_grapple_return)

const LAYER_GRAPPLE_OBSTACLES: int = 3
func _grapple_player() -> void:
    Audio.play_spatial_sound(stick_audio, player.global_position)
    if tween:
        tween.kill()

    # disable player's related collision
    player.set_collision_mask_value(LAYER_GRAPPLE_OBSTACLES, false)
    var dur: float = collision_dist / grapple_speed
    tween = create_tween()
    tween.tween_property(nine_patch_rect, "size", Vector2(nine_patch_rect.size.x, nine_patch_size), dur)

    var target_pos: Vector2 = player.global_position + player.cardinal_dir * collision_dist
    # adjust hook
    # hook handle = 16px, hook head = 9px, position coord at end of handle
    # up:
    #   player_pos - 20, 20 + 16 + x + 9 = dist, x = dist - 45
    # down:
    #   player_pos - 10, 6 + x + 9 = dist, x = dist - 15
    # left:
    #   player_pos - 10, 10 + 16 + x + 9 = dist, x = dist - 35
    # right:
    #   player_pos + 10, 10 + 16 + x + 9 = dist, x = dist - 35
    match player.cardinal_dir:
        Vector2.UP:
            target_pos -= player.cardinal_dir * 45 * .5
        Vector2.DOWN:
            target_pos -= player.cardinal_dir * 15 * .5
        _:
            target_pos -= player.cardinal_dir * 35 * .5
    tween.parallel().tween_property(player, "global_position", target_pos, dur).set_ease(Tween.EASE_OUT)
    player.damage_area.make_invulnerable(dur)
    tween.tween_callback(_grapple_finished)

func _grapple_return() -> void:
    if tween:
        tween.kill()

    if collision_type > 0:
        Audio.play_spatial_sound(clang_audio, collision_pos)

    var dur: float = collision_dist / grapple_speed
    tween = create_tween()
    tween.tween_property(nine_patch_rect, "size", Vector2(nine_patch_rect.size.x, nine_patch_size), dur)
    tween.tween_callback(_grapple_finished)

func _grapple_finished() -> void:
    # restore player's related collision
    player.set_collision_mask_value(LAYER_GRAPPLE_OBSTACLES, true)
    player.fsm.change_state(player.fsm.idle)
